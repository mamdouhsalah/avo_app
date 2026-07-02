// the screen that doctor will interact with to do actions with appointments
import 'package:avo_app/app/core/Language/locale_keys.g.dart';
import 'package:avo_app/app/core/models/patient_model.dart';
import 'package:avo_app/app/core/routing/app_router.dart';
import 'package:avo_app/app/core/services/remote/firestore_chats_services.dart';
import 'package:avo_app/app/core/shared/custom_avatar.dart';
import 'package:avo_app/app/core/models/doctor_model.dart';
import 'package:avo_app/app/core/shared/main_button.dart';
import 'package:avo_app/app/features/appointment/logic/appointment_cubit.dart';
import 'package:avo_app/app/features/doctor/helpers/status_hlper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:avo_app/app/core/models/appointment_model.dart';

class AppointmentActionScreen extends StatelessWidget {
  final PatientModel patient;
  final String appointmentId;
  final String appointmentStatus;

  const AppointmentActionScreen(
      {super.key,
      required this.patient,
      required this.appointmentId,
      required this.appointmentStatus});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nextStatus = AppointmentStatusHelper.getNextStatus(appointmentStatus);
    final String actionText = nextStatus == AppointmentStatus.confirmed
    ? 'Confirm'
    : 'Complete';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Patient Details'),
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
            context.pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========== Top Card ==========
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
                    size: 45.r, // Reduced size as requested
                    borderColor: theme.colorScheme.primary,
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.fullName,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          patient.email,
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            // ========== Details Section ==========
            Text(
              "Personal Information",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 16.h),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildInfoRow(context, Icons.calendar_today_rounded,
                      "Date of Birth", patient.dateOfBirth),
                  Divider(height: 1, color: theme.colorScheme.outlineVariant),
                  _buildInfoRow(context, Icons.person_outline_rounded, "Gender",
                      patient.gender),
                  Divider(height: 1, color: theme.colorScheme.outlineVariant),
                  _buildInfoRow(context, Icons.phone_rounded, "Phone",
                      patient.phoneNumber),
                  Divider(height: 1, color: theme.colorScheme.outlineVariant),
                  _buildInfoRow(
                      context, Icons.email_rounded, "Email", patient.email),
                  Divider(height: 1, color: theme.colorScheme.outlineVariant),
                  SizedBox(height: 50.h),
                  if (nextStatus != null) ...[
                    MainButton(
                      text: actionText,
                      onPressed: () async {
                        switch (nextStatus) {
                          case AppointmentStatus.confirmed:
                            context
                                .read<AppointmentCubit>()
                                .confirmAppointment(appointmentId);
                            break;

                          case AppointmentStatus.completed:
                            context
                                .read<AppointmentCubit>()
                                .completeAppointment(appointmentId);
                            break;
                        }
                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            content: Text(
                              'done successfully',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );

                        // Wait a little so the user sees the snackbar
                        await Future.delayed(const Duration(milliseconds: 700));

                        if (!context.mounted) return;
                        context.go(AppRouter.appointments);
                      },
                    ),

                    SizedBox(height: 12.h),

                    // Show Cancel only when appointment is already confirmed
                    if (appointmentStatus == AppointmentStatus.confirmed ||
                        appointmentStatus == AppointmentStatus.pending) ...[
                      SizedBox(height: 12.h),
                      MainButton(
                        text: "Cancel",
                        onPressed: () async {
                          context
                              .read<AppointmentCubit>()
                              .cancelAppointment(appointmentId);
                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              content: Text(
                                'Appointment canceled successfully',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );

                          // Wait a little so the user sees the snackbar
                          await Future.delayed(
                              const Duration(milliseconds: 700));

                          if (!context.mounted) return;
                          context.go(AppRouter.appointments);
                        },
                      ),
                    ],
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, IconData icon, String title, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
