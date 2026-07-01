import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:avo_app/app/core/services/local/gemini_service.dart';
import 'package:avo_app/app/core/services/local/hive_medical_analysis_service.dart';
import 'package:avo_app/app/core/services/remote/sync_repository.dart';
import 'package:avo_app/app/core/services/remote/cloudinary_service.dart';
import 'package:avo_app/app/core/routing/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:avo_app/app/core/Language/locale_keys.g.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  late ScrollController _scrollController;
  late ScrollController _markDownScrollController;
  late TextEditingController _nameController;

  File? _image;
  String _extractedText = "";
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
      _showSnackBar(LocaleKeys.scanner_storage_init_failed.tr(args: [e.toString()]));
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
          _showSnackBar(LocaleKeys.scanner_camera_permission_denied.tr());
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

        _displayedText = "";
        saved = false;
      });
      
      _extractTextFromImage(_image!);
    } catch (e) {
      _showSnackBar(LocaleKeys.scanner_image_pick_error.tr(args: [e.toString()]));
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
              child: Text(LocaleKeys.scanner_image_source.tr(), style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 18.sp)),
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: Theme.of(context).colorScheme.primary),
              title: Text(LocaleKeys.scanner_take_photo.tr(), style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
              subtitle: Text(LocaleKeys.scanner_take_new_photo.tr(), style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.photo_library, color: Theme.of(context).colorScheme.primary),
              title: Text(LocaleKeys.scanner_choose_gallery.tr(), style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
              subtitle: Text(LocaleKeys.scanner_choose_gallery_sub.tr(), style: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey)),
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
        _showSnackBar(LocaleKeys.scanner_no_text_recognized.tr());
      }
      await textRecognizer.close();
    } catch (e) {
      _showSnackBar(LocaleKeys.scanner_text_extract_failed.tr(args: [e.toString()]));
    }
  }

  Future<void> _analyzeText(String extractedText) async {
    setState(() => _isAnalyzing = true);

    try {
      final analysis = await _geminiService.sendMessage(
        LocaleKeys.scanner_gemini_prompt.tr(args: [extractedText])
      );
      if (analysis is GeminiSuccess) {
        _startTyping(analysis.text);
      } else if (analysis is GeminiError) {
        throw Exception(analysis.message);
      }
    } catch (e) {
      log("Analysis failed: $e");
      _showSnackBar(LocaleKeys.scanner_analysis_failed.tr());
      setState(() {
        _isAnalyzing = false;
        _displayedText = LocaleKeys.scanner_analysis_failed_quota.tr(args: [extractedText]);
      });
    }
  }

  /// Save data locally without any AI dependency
  Future<void> _saveData() async {
    if (!_isServiceInitialized) {
      _showSnackBar(LocaleKeys.scanner_storage_not_ready.tr());
      return;
    }
    
    final syncRepo = context.read<SyncRepository>();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (selectedDate == null) return;

    setState(() => _isAnalyzing = true);

    try {
      String? uploadedImageUrl;
      if (_image != null) {
        // Upload image to Cloudinary
        _showSnackBar(LocaleKeys.scanner_uploading_image.tr());
        uploadedImageUrl = await CloudinaryService().uploadImage(_image!);
      }

      // Save locally directly - no AI parsing needed
      final fullDescription = "${LocaleKeys.scanner_extracted_text_label.tr()}:\n$_extractedText\n\n${LocaleKeys.scanner_analysis_label.tr()}:\n$_displayedText";
      final analysisName = _nameController.text.isNotEmpty 
            ? _nameController.text 
            : "${LocaleKeys.scanner_default_analysis_name.tr()} - ${DateTime.now().toString().split(' ').first}";
      await _medicalAnalysisService.addAnalysisData(
        analysisName: analysisName,
        stateName: LocaleKeys.scanner_analysis_results_state.tr(),
        value: 0.0,
        normalLimits: "N/A",
        description: fullDescription,
        imageUrl: uploadedImageUrl,
        date: selectedDate,
      );
      
      // Fetch the updated analysis and push to Firebase
      final updatedAnalyses = _medicalAnalysisService.getAllAnalyses();
      final targetAnalysis = updatedAnalyses.firstWhere(
        (a) => a.analysisName.toLowerCase() == analysisName.toLowerCase(),
      );
      
      await syncRepo.pushAnalysisToRemote(targetAnalysis);

      setState(() => saved = true);
      _showSnackBar(LocaleKeys.scanner_analysis_saved_successfully.tr());
    } catch (saveError) {
      _showSnackBar(LocaleKeys.scanner_data_save_failed.tr(args: [saveError.toString()]));
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.scanner_medical_analysis.tr(), style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
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
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade900 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Theme.of(context).dividerColor, width: 2),
                ),
                child: _image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20.r),
                        child: Image.file(_image!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 50.sp, color: Theme.of(context).colorScheme.primary),
                          SizedBox(height: 10.h),
                          Text(LocaleKeys.scanner_tap_scan.tr(), style: const TextStyle(fontFamily: 'Cairo')),
                          Text(LocaleKeys.scanner_camera_or_gallery.tr(), style: TextStyle(fontFamily: 'Cairo', fontSize: 12.sp, color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey)),
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
                      label: Text(LocaleKeys.scanner_camera.tr(), style: const TextStyle(fontFamily: 'Cairo', color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: Icon(Icons.photo_library, color: Theme.of(context).colorScheme.primary),
                      label: Text(LocaleKeys.scanner_gallery.tr(), style: TextStyle(fontFamily: 'Cairo', color: Theme.of(context).colorScheme.primary)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          side: BorderSide(color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            SizedBox(height: 20.h),
            if (_isAnalyzing)
              Shimmer.fromColors(
                baseColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade300,
                highlightColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade600 : Colors.white,
                child: Container(
                  height: 100.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                ),
              )
            else if (_displayedText.isNotEmpty)
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
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
                        labelText: LocaleKeys.scanner_analysis_name.tr(),
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
                          label: Text(LocaleKeys.scanner_save_analysis.tr(), style: const TextStyle(fontFamily: 'Cairo', color: Colors.white)),
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
                            Text(LocaleKeys.scanner_saved_success.tr(), style: const TextStyle(fontFamily: 'Cairo', color: Colors.green, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'history_fab',
            onPressed: () {
              context.push(AppRouter.savedAnalysisList);
            },
            backgroundColor: const Color(0xFF1ABC9C),
            child: const Icon(Icons.history, color: Colors.white),
          ),
          if (_image != null && !_isAnalyzing) ...[
            const SizedBox(height: 16),
            FloatingActionButton(
              heroTag: 'camera_fab',
              onPressed: _showPickOptions,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.camera_alt, color: Colors.white),
            ),
          ]
        ],
      ),
    );
  }
}
