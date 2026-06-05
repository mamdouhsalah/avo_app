// details_patient_screen.dart
import 'package:avo_app/app/core/models/chatmodel.dart';
import 'package:avo_app/app/core/models/patient_model.dart';
import 'package:avo_app/app/core/shared/CustomAvatar.dart';
import 'package:avo_app/app/features/doctor/data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class DetailsPatientScreen extends StatelessWidget {
  final PatientModel patient;

  const DetailsPatientScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Details'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: theme.textTheme.titleLarge?.color,
            size: 24.sp,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========== Top Patient Card ==========
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 20,
                    color: theme.colorScheme.shadow.withValues(alpha: 0.08),
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CustomAvatar(
                    imageUrl: patient.image,
                    size: 60.r,
                    borderColor: theme.colorScheme.primary,
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.name,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          patient.diagnosis ?? "No Diagnosis",
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.mark_unread_chat_alt_rounded,
                        color: theme.colorScheme.primary,
                        size: 22.sp,
                      ),
                      onPressed: () {
                        context.push('/chat-details',
                            extra: ChatModel(
                              id: 'chat_${patient.id}',
                              patient: patient,
                              doctor: DataRepository.doctors[0],
                              lastMessage: 'View patient details',
                              lastMessageTime: DateTime.now(),
                              unreadCount: 0,
                              isOnline: false,
                              lastMessageSender: 'doctor',
                            ));
                      },
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            Text(
              "Patient Information",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),

            // ========== Info Rows ==========
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  _buildInfoRow("Date of Birth", "Dec 12, 1998"),
                  _buildDivider(),
                  _buildInfoRow("Marital Status", "Married"),
                  _buildDivider(),
                  _buildInfoRow("Social Number", "034824"),
                  _buildDivider(),
                  _buildInfoRow("Gender", "Female"),
                  _buildDivider(),
                  _buildInfoRow("Insurance", "Delta Tech"),
                  _buildDivider(),
                  _buildInfoRow("Phone Number", patient.phone),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // ========== Tabs ==========
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        "Upcoming",
                        style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      border: Border.all(
                          color:
                              theme.colorScheme.outline.withValues(alpha: 0.2)),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Center(
                      child: Text(
                        "Past",
                        style: TextStyle(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // ========== Appointments List ==========
            _buildAppointmentItem(
                "12 Dec",
                patient.diagnosis ?? "Routine Checkup",
                "Follow-up",
                "Dr. David Brown",
                "Confirm",
                theme),
            _buildAppointmentItem(
                "16 Dec",
                patient.diagnosis ?? "Routine Checkup",
                "Follow-up",
                "Dr. David Brown",
                "Pending",
                theme),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Divider(height: 1, color: Colors.grey.withValues(alpha: 0.2)),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentItem(String date, String symptoms, String category,
      String doctor, String status, ThemeData theme) {
    final bool isConfirmed = status == "Confirm";
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: [
                Text(date.split(" ")[0],
                    style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary)),
                Text(date.split(" ")[1],
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary.withValues(alpha: 0.7),
                    )),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(symptoms,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.person_outline,
                        size: 14.sp, color: Colors.grey[600]),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(doctor,
                          style: TextStyle(
                              fontSize: 13.sp, color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: isConfirmed
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              status,
              style: TextStyle(
                  color: isConfirmed ? Colors.green : Colors.orange,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
