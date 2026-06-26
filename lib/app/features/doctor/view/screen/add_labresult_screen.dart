import 'dart:io';
import 'package:avo_app/app/core/models/doctor_model.dart';
import 'package:avo_app/app/core/models/lab_result_model.dart';
import 'package:avo_app/app/core/models/patient_model.dart';
import 'package:avo_app/app/features/doctor/services/labresult_service.dart';
import 'package:avo_app/app/features/doctor/view/widget/patient_search_bottom_sheet.dart';
import 'package:avo_app/app/features/doctor/data/doctor_repository_impl.dart';
import 'package:avo_app/app/core/services/remote/firebase_consumer_impl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class AddLabResultScreen extends StatefulWidget {
  final XFile file;
  final bool isAI;

  const AddLabResultScreen({
    super.key,
    required this.file,
    required this.isAI,
  });

  @override
  State<AddLabResultScreen> createState() => _AddLabResultScreenState();
}

class _AddLabResultScreenState extends State<AddLabResultScreen> {
  final _formKey = GlobalKey<FormState>();

  late bool _isAnalyzing;

  // Form controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  PatientModel? _selectedPatient;
  List<PatientModel> _patients = [];
  late final DoctorRepositoryImpl _doctorRepo;
  final String _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _isAnalyzing = widget.isAI;

    _doctorRepo = DoctorRepositoryImpl(consumer: FirebaseConsumerImpl());
    _loadPatients();

    if (_isAnalyzing) {
      _simulateAIAnalysis();
    } else {
      _prefillManual();
    }
  }

  Future<void> _loadPatients() async {
    final patients = await _doctorRepo.getDoctorPatients(_currentUid);
    if (mounted) {
      setState(() {
        _patients = patients;
        if (_patients.isNotEmpty) {
          _selectedPatient = _patients.first;
        }
      });
    }
  }

  void _prefillManual() {
    _titleController.text = "Manual Lab Result";
    _descriptionController.text = "Lab result added manually";
    _summaryController.text = "";
    _notesController.text = "";
  }

  Future<void> _simulateAIAnalysis() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) {
      setState(() {
        _isAnalyzing = false;

        String fileName = widget.file.name.toLowerCase();
        if (fileName.contains('blood') || fileName.contains('cbc')) {
          _titleController.text = "AI Extracted: Blood CBC Analysis";
          _descriptionController.text = "Complete Blood Count analysis report";
          _summaryController.text =
              "Hemoglobin: 14.2 g/dL (Normal)\nWhite Blood Cells: 6.5 x10^3/uL (Normal)\nPlatelets: 250 x10^3/uL (Normal)\nAll indicators are within standard biological references.";
        } else if (fileName.contains('xray') ||
            fileName.contains('x-ray') ||
            fileName.contains('chest')) {
          _titleController.text = "AI Extracted: Chest X-Ray";
          _descriptionController.text =
              "Chest & lung radiological imaging report";
          _summaryController.text =
              "Lung fields are clear bilaterally. No pleural effusion or pneumothorax. Cardiomediastinal contour is normal. Bony thorax is intact without fracture.";
        } else {
          _titleController.text = "AI Extracted: Medical Lab Report";
          _descriptionController.text =
              "Automated document scanning and analysis";
          _summaryController.text =
              "AI extracted summary: The uploaded document has been analyzed successfully. General health biomarkers appear within normal limits. No immediate critical warning signs detected.";
        }
        _notesController.text = "AI processed automatically.";
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _summaryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showSearchablePatientBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.6,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return PatientSearchBottomSheet(
              patients: _patients,
              selectedPatient: _selectedPatient,
              onPatientSelected: (patient) {
                setState(() {
                  _selectedPatient = patient;
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  void _saveResult() {
    if (_formKey.currentState!.validate()) {
      if (_selectedPatient == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please select a patient'),
              backgroundColor: Colors.red),
        );
        return;
      }
      final newResult = LabResultModel(
        id: "lr_${DateTime.now().millisecondsSinceEpoch}",
        title: _titleController.text.trim(),
        patientId: _selectedPatient!.id,
        doctorId: _currentUid,
        patientName: _selectedPatient!.fullName,
        doctorName: 'Doctor', // Could fetch from prefs or pass it down
        description: _descriptionController.text.trim(),
        dateTime: DateTime.now(),
        fileType: widget.file.name.split('.').last.toLowerCase(),
        typeAdd: widget.isAI ? "AI" : "Manual",
        resultSummary: _summaryController.text.trim().isNotEmpty
            ? _summaryController.text.trim()
            : null,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        fileUrl: widget.file.path,
      );

      // Add to repository
      LabResultService.labResults.add(newResult);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${newResult.title}" saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isAnalyzing) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.sp),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox(
                    width: 80.w,
                    height: 80.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                SizedBox(height: 32.h),
                Text(
                  "AI Document Scanning",
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  "Extracting medical terms, patient records, and analysis summaries from \"${widget.file.name}\"...",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.isAI
            ? "AI Patient Data Entry"
            : "Manual Patient Data Entry"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(Icons.close,
              color: theme.colorScheme.onSurface, size: 24.sp),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.sp),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Document Preview Card ────────────────────────
              Text(
                "Uploaded Document",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                height: 150.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey[300]!),
                  color: Colors.grey[50],
                ),
                clipBehavior: Clip.antiAlias,
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: widget.file.path.toLowerCase().endsWith('.pdf')
                          ? Container(
                              color: Colors.red[50],
                              child: Center(
                                child: Icon(
                                  Icons.picture_as_pdf,
                                  color: Colors.red,
                                  size: 48.sp,
                                ),
                              ),
                            )
                          : Image.file(
                              File(widget.file.path),
                              fit: BoxFit.cover,
                            ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Padding(
                        padding: EdgeInsets.all(12.sp),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.file.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              "Method: ${widget.isAI ? 'AI Detection' : 'Manual Entry'}",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: widget.isAI
                                    ? Colors.purple
                                    : Colors.orange[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            FutureBuilder<int>(
                              future: File(widget.file.path).length(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  final kb = (snapshot.data! / 1024)
                                      .toStringAsFixed(1);
                                  return Text(
                                    "Size: $kb KB",
                                    style: TextStyle(
                                        fontSize: 11.sp,
                                        color: Colors.grey[500]),
                                  );
                                }
                                return const SizedBox();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              // ── Patient Dropdown ──────────────────────────────
              Text(
                "Select Patient",
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),

              GestureDetector(
                onTap: () => _showSearchablePatientBottomSheet(),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.person_outline, color: Colors.grey[600]),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          _selectedPatient?.fullName ?? "Choose Patient",
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: _selectedPatient == null
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                    ],
                  ),
                ),
              ),
              if (_selectedPatient != null) ...[
                SizedBox(height: 8.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Row(
                    children: [
                      Icon(Icons.phone, size: 12.sp, color: Colors.grey[600]),
                      SizedBox(width: 4.w),
                      Text(
                        _selectedPatient!.phoneNumber,
                        style:
                            TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                      ),
                      const Spacer(),
                      if (_selectedPatient!.diagnosis != null) ...[
                        Icon(Icons.healing_outlined,
                            size: 12.sp, color: Colors.grey[600]),
                        SizedBox(width: 4.w),
                        Text(
                          _selectedPatient!.diagnosis!,
                          style: TextStyle(
                              fontSize: 12.sp, color: Colors.grey[600]),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              SizedBox(height: 20.h),

              // ── General Info Form Fields ─────────────────────
              Text(
                "Report details",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12.h),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Report Title',
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? 'Please enter a title'
                    : null,
              ),
              SizedBox(height: 16.h),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  prefixIcon: const Icon(Icons.description_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? 'Please enter a description'
                    : null,
              ),
              SizedBox(height: 16.h),

              // Result Summary
              TextFormField(
                controller: _summaryController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Result Summary',
                  alignLabelWithHint: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 50.h),
                    child: const Icon(Icons.summarize_outlined),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Additional Notes',
                  alignLabelWithHint: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 30.h),
                    child: const Icon(Icons.notes_outlined),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // ── Save Button ──────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveResult,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    "Save & Close",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
