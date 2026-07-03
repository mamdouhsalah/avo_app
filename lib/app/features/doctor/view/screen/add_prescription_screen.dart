import 'package:avo_app/app/core/models/medicine_model.dart';
import 'package:avo_app/app/core/models/patient_model.dart';
import 'package:avo_app/app/core/services/remote/firebase_consumer_impl.dart';
import 'package:avo_app/app/features/doctor/data/doctor_repository_impl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddPrescriptionScreen extends StatefulWidget {
  final PatientModel patient;

  const AddPrescriptionScreen({super.key, required this.patient});

  @override
  State<AddPrescriptionScreen> createState() => _AddPrescriptionScreenState();
}

class _AddPrescriptionScreenState extends State<AddPrescriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _timeController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isSaving = false;
  late final DoctorRepositoryImpl _doctorRepo;

  @override
  void initState() {
    super.initState();
    _doctorRepo = DoctorRepositoryImpl(consumer: FirebaseConsumerImpl());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _timeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _savePrescription() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final String currentDoctorId = FirebaseAuth.instance.currentUser?.uid ?? '';
      
      final medicine = MedicineModel(
        id: "med_${DateTime.now().millisecondsSinceEpoch}",
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        time: _timeController.text.trim(),
        isTaken: false,
        doctorId: currentDoctorId,
        patientId: widget.patient.id,
        date: DateTime.now(),
        instructions: _notesController.text.trim(),
      );

      await _doctorRepo.addPrescription(widget.patient.id, medicine);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prescription added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving prescription: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Add Prescription'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.sp),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Prescribing for: ${widget.patient.fullName}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(height: 24.h),
              
              _buildTextField(
                controller: _nameController,
                label: 'Medicine Name',
                icon: Icons.medication,
                validator: (v) => v!.isEmpty ? 'Please enter medicine name' : null,
              ),
              SizedBox(height: 16.h),
              
              _buildTextField(
                controller: _dosageController,
                label: 'Dosage (e.g., 500mg)',
                icon: Icons.scale,
                validator: (v) => v!.isEmpty ? 'Please enter dosage' : null,
              ),
              SizedBox(height: 16.h),
              
              _buildTextField(
                controller: _timeController,
                label: 'Frequency (e.g., Twice a day)',
                icon: Icons.access_time,
                validator: (v) => v!.isEmpty ? 'Please enter frequency' : null,
              ),
              SizedBox(height: 16.h),
              
              _buildTextField(
                controller: _notesController,
                label: 'Instructions / Notes (Optional)',
                icon: Icons.notes,
                maxLines: 3,
              ),
              
              SizedBox(height: 32.h),
              
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _savePrescription,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          'Save Prescription',
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}
