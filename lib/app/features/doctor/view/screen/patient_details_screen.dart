import 'package:avo_app/app/core/models/lab_result_model.dart';
import 'package:avo_app/app/core/models/medicine_model.dart';
import 'package:avo_app/app/core/models/patient_model.dart';
import 'package:avo_app/app/core/services/remote/firebase_consumer_impl.dart';
import 'package:avo_app/app/core/shared/custom_avatar.dart';
import 'package:avo_app/app/features/doctor/data/doctor_repository_impl.dart';
import 'package:avo_app/app/features/doctor/view/screen/add_prescription_screen.dart';
import 'package:avo_app/app/features/doctor/view/screen/labresult_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class PatientDetailsScreen extends StatefulWidget {
  final PatientModel patient;

  const PatientDetailsScreen({super.key, required this.patient});

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final DoctorRepositoryImpl _doctorRepo;

  bool _isLoading = true;
  List<LabResultModel> _labResults = [];
  List<MedicineModel> _medicines = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _doctorRepo = DoctorRepositoryImpl(consumer: FirebaseConsumerImpl());
    _loadPatientData();
  }

  Future<void> _loadPatientData() async {
    setState(() => _isLoading = true);
    try {
      final labs = await _doctorRepo.getLabResults(widget.patient.id);
      final meds = await _doctorRepo.getPatientMedicines(widget.patient.id);
      if (mounted) {
        setState(() {
          _labResults = labs;
          _medicines = meds;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = widget.patient;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Patient Record'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16.sp),
            child: Row(
              children: [
                CustomAvatar(
                  imageUrl: p.image,
                  size: 60.sp,
                  radius: 30.r,
                  borderColor: theme.colorScheme.primary,
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.fullName,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        p.email,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(Icons.phone,
                              size: 14.sp, color: Colors.grey[500]),
                          SizedBox(width: 4.w),
                          Text(
                            p.phoneNumber.isNotEmpty
                                ? p.phoneNumber
                                : 'No phone provided',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          TabBar(
            controller: _tabController,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: theme.colorScheme.primary,
            tabs: const [
              Tab(text: 'Prescriptions'),
              Tab(text: 'Lab Results'),
            ],
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPrescriptionsTab(theme),
                      _buildLabResultsTab(theme),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddPrescriptionScreen(patient: widget.patient),
            ),
          );
          if (result == true) {
            _loadPatientData();
          }
        },
        icon: const Icon(Icons.medical_information_sharp),
        label: const Text(''),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildPrescriptionsTab(ThemeData theme) {
    if (_medicines.isEmpty) {
      return const Center(child: Text('No prescriptions found.'));
    }
    return ListView.builder(
      padding: EdgeInsets.all(16.sp),
      itemCount: _medicines.length,
      itemBuilder: (context, index) {
        final m = _medicines[index];
        final dateStr = m.date != null
            ? DateFormat.yMMMd().format(m.date!)
            : 'Unknown Date';

        return Card(
          margin: EdgeInsets.only(bottom: 12.h),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          elevation: 2,
          child: ListTile(
            onTap: () {
              showModalBottomSheet(
                context: context,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                ),
                builder: (context) => Container(
                  padding: EdgeInsets.all(24.sp),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.purple.withValues(alpha: 0.1),
                            radius: 24.r,
                            child: Icon(Icons.medication, color: Colors.purple, size: 28.sp),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(m.name,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 20.sp)),
                                SizedBox(height: 4.h),
                                Text(dateStr,
                                    style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      _buildDetailRow(Icons.monitor_weight_outlined, 'Dosage', m.dosage),
                      SizedBox(height: 16.h),
                      _buildDetailRow(Icons.access_time, 'Frequency', m.time),
                      if (m.instructions != null && m.instructions!.isNotEmpty) ...[
                        SizedBox(height: 16.h),
                        _buildDetailRow(Icons.info_outline, 'Instructions', m.instructions!),
                      ],
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
              );
            },
            contentPadding: EdgeInsets.all(12.sp),
            leading: CircleAvatar(
              backgroundColor: Colors.purple.withValues(alpha: 0.1),
              child: const Icon(Icons.medication, color: Colors.purple),
            ),
            title: Text(m.name,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4.h),
                Text('Dosage: ${m.dosage} | Freq: ${m.time}'),
                if (m.instructions != null && m.instructions!.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text('Notes: ${m.instructions}',
                      style: TextStyle(fontStyle: FontStyle.italic)),
                ],
                SizedBox(height: 4.h),
                Text(dateStr,
                    style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabResultsTab(ThemeData theme) {
    if (_labResults.isEmpty) {
      return const Center(child: Text('No lab results found.'));
    }
    return ListView.builder(
      padding: EdgeInsets.all(16.sp),
      itemCount: _labResults.length,
      itemBuilder: (context, index) {
        final r = _labResults[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12.h),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.withValues(alpha: 0.1),
              child: const Icon(Icons.science, color: Colors.blue),
            ),
            title: Text(r.title, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(r.formattedDate),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => LabresultDetailScreen(result: r)));
            },
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20.sp, color: Colors.grey[600]),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16.sp),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
