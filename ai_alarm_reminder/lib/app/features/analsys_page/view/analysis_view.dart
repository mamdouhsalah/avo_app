import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:ai_alarm_reminder/app/core/services/points_service.dart';
import 'package:ai_alarm_reminder/app/core/services/gemini_service.dart';
import 'package:ai_alarm_reminder/app/core/services/service_models/hive_medical_analysis_service.dart';
import 'package:ai_alarm_reminder/app/core/utils/constance.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AnalysisViewPage extends StatefulWidget {
  const AnalysisViewPage({super.key});

  @override
  State<AnalysisViewPage> createState() => _AnalysisViewPageState();
}

class _AnalysisViewPageState extends State<AnalysisViewPage> {
  late ScrollController _scrollController;
  late ScrollController _markDownScrollController;
  late TextEditingController _nameController;

  File? _image;
  String _extractedText = "";
  String _analysisResult = "";
  String _displayedText = "";
  bool saved = false;
  bool _isAnalyzing = false;
  int _currentIndex = 0;
  late Timer _timer;
  bool _isServiceInitialized = false;

  late GeminiService _geminiService;
  late MedicalAnalysisService _medicalAnalysisService;

  @override
  void initState() {
    super.initState();
    _geminiService = GeminiService();
    _medicalAnalysisService = MedicalAnalysisService();
    _initializeServices();
    _scrollController = ScrollController();
    _markDownScrollController = ScrollController();
    _nameController = TextEditingController();
    _nameController.text = "تحليل جديد - ${DateTime.now().toString().split(' ').first}";
    _timer = Timer.periodic(Duration.zero, (timer) {});
    
    // Open picker immediately when entering page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPickOptions();
    });
  }

  Future<void> _initializeServices() async {
    try {
      await _medicalAnalysisService.init();
      setState(() => _isServiceInitialized = true);
    } catch (e) {
      _showSnackBar("فشل في تهيئة التخزين: $e");
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    _markDownScrollController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _startTyping(String text) {
    setState(() {
      _isAnalyzing = false;
      _currentIndex = 0;
      _displayedText = '';
    });

    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (_currentIndex < text.length) {
        setState(() {
          _displayedText += text[_currentIndex];
          _currentIndex++;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 50),
              curve: Curves.easeOut,
            );
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Cairo')),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        final status = await Permission.camera.request();
        if (!status.isGranted) {
          _showSnackBar("يرجى منح إذن الكاميرا من الإعدادات");
          return;
        }
      }
      // For gallery, modern ImagePicker handles it without explicit storage permissions.

      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (photo == null) return;

      setState(() {
        _image = File(photo.path);
        _extractedText = "";
        _analysisResult = "";
        _displayedText = "";
        saved = false;
      });
      
      _extractTextFromImage(_image!);
    } catch (e) {
      _showSnackBar("خطأ في اختيار الصورة: $e");
    }
  }

  void _showPickOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text('اختر مصدر الصورة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 18.sp)),
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppColors.primaryColor),
              title: const Text('الكاميرا', style: TextStyle(fontFamily: 'Cairo')),
              subtitle: const Text('التقط صورة جديدة', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppColors.primaryColor),
              title: const Text('المعرض', style: TextStyle(fontFamily: 'Cairo')),
              subtitle: const Text('اختر صورة من المعرض', style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Future<void> _extractTextFromImage(File image) async {
    try {
      final inputImage = InputImage.fromFile(image);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      
      setState(() => _extractedText = recognizedText.text);
      
      if (_extractedText.isNotEmpty) {
        _analyzeText(_extractedText);
      } else {
        _showSnackBar("لم يتم التعرف على أي نص في الصورة.");
      }
      await textRecognizer.close();
    } catch (e) {
      _showSnackBar("فشل استخراج النص: $e");
    }
  }

  Future<void> _analyzeText(String extractedText) async {
    if (PointsService.points < 1) {
      _showSnackBar("ليس لديك نقاط كافية للفحص. يرجى تسجيل بيانات صحية للحصول على نقاط.");
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      await PointsService.spendPoints(1);
      final analysis = await _geminiService.sendMessage(
        "أنت مساعد طبي، قم بتحليل نتائج المختبر التالية باللغة العربية العامية: $extractedText. "
        "اشرح النتائج ببساطة ووضوح ووجه المريض للتخصص المناسب."
      );
      _startTyping(analysis);
    } catch (e) {
      log("Analysis failed: $e");
      _showSnackBar('حدث خطأ أثناء التحليل بالذكاء الاصطناعي. يمكنك حفظ النص المستخرج يدوياً.');
      setState(() {
        _isAnalyzing = false;
        _displayedText = "فشل التحليل الذكي (Quota Exceeded أو مشكلة اتصال).\n\nالنص المستخرج من الصورة:\n$extractedText";
      });
    }
  }

  /// Save data locally without any AI dependency
  Future<void> _saveData() async {
    if (!_isServiceInitialized) {
      _showSnackBar("التخزين غير جاهز بعد، يرجى الانتظار...");
      return;
    }
    
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (selectedDate == null) return;

    setState(() => _isAnalyzing = true);

    try {
      // Save locally directly - no AI parsing needed
      final fullDescription = "النص المستخرج:\n$_extractedText\n\nالتحليل:\n$_displayedText";
      await _medicalAnalysisService.addAnalysisData(
        analysisName: _nameController.text.isNotEmpty 
            ? _nameController.text 
            : "تحليل - ${DateTime.now().toString().split(' ').first}",
        stateName: "نتائج التحليل",
        value: 0.0,
        normalLimits: "N/A",
        description: fullDescription,
        date: selectedDate,
      );
      setState(() => saved = true);
      _showSnackBar("تم حفظ التحليل بنجاح ✅");
    } catch (saveError) {
      _showSnackBar("فشل حفظ البيانات: $saveError");
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('فحص التحاليل', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        actions: [
          if (_displayedText.isNotEmpty && !saved)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveData,
              tooltip: 'حفظ التحليل',
            )
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            GestureDetector(
              onTap: _showPickOptions,
              child: Container(
                height: 250.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                ),
                child: _image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20.r),
                        child: Image.file(_image!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 50.sp, color: AppColors.primaryColor),
                          SizedBox(height: 10.h),
                          const Text('اضغط لمسح صورة التحليل', style: TextStyle(fontFamily: 'Cairo')),
                          Text('(كاميرا أو معرض الصور)', style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp, color: Colors.grey)),
                        ],
                      ),
              ),
            ),
            SizedBox(height: 12.h),
            // Quick action buttons for camera and gallery
            if (_image == null)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      label: const Text('الكاميرا', style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: Icon(Icons.photo_library, color: AppColors.primaryColor),
                      label: Text('المعرض', style: TextStyle(fontFamily: 'Cairo', color: AppColors.primaryColor)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          side: BorderSide(color: AppColors.primaryColor),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            SizedBox(height: 20.h),
            if (_isAnalyzing)
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.white,
                child: Container(
                  height: 100.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                ),
              )
            else if (_displayedText.isNotEmpty)
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.r),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name field for the analysis
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'اسم التحليل',
                        labelStyle: const TextStyle(fontFamily: 'Cairo'),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      ),
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                    SizedBox(height: 12.h),
                    MarkdownBody(
                      data: _displayedText,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(fontFamily: 'Cairo', fontSize: 14.sp),
                      ),
                    ),
                    if (!saved) ...[
                      SizedBox(height: 16.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _saveData,
                          icon: const Icon(Icons.save, color: Colors.white),
                          label: const Text('حفظ التحليل', style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                          ),
                        ),
                      ),
                    ] else
                      Padding(
                        padding: EdgeInsets.only(top: 12.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 8),
                            const Text('تم الحفظ بنجاح', style: TextStyle(fontFamily: 'Cairo', color: Colors.green, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: _image != null && !_isAnalyzing
          ? FloatingActionButton.extended(
              onPressed: _showPickOptions,
              label: const Text('صورة جديدة', style: TextStyle(fontFamily: 'Cairo')),
              icon: const Icon(Icons.camera_alt),
              backgroundColor: AppColors.primaryColor,
            )
          : null,
    );
  }
}
