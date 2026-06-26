import 'package:avo_app/app/core/models/chatmodel.dart';
import 'package:avo_app/app/core/models/patient_model.dart';
import 'package:avo_app/app/core/services/remote/firebase_consumer_impl.dart';
import 'package:avo_app/app/core/services/remote/firestore_chats_services.dart';
import 'package:avo_app/app/core/shared/custom_avatar.dart';
import 'package:avo_app/app/core/models/doctor_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class UserDetailsScreen extends StatelessWidget {
  final dynamic user;

  const UserDetailsScreen({super.key, required this.user});

  bool get isDoctor => user is DoctorModel;
  String get name => isDoctor ? user.name : user.fullName;
  String? get image => isDoctor ? user.imageUrl : user.image;
  String get role => isDoctor ? user.specialty : (user.diagnosis ?? "No Diagnosis");
  String? get phone => isDoctor ? null : user.phoneNumber;
  String? get email => isDoctor ? null : user.email;
  String? get dateOfBirth => isDoctor ? null : user.dateOfBirth;
  String? get gender => isDoctor ? null : user.gender;

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
                    imageUrl: image,
                    size: 45.r, // Reduced size as requested
                    borderColor: theme.colorScheme.primary,
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          role,
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
                      onPressed: () async {
                        final currentUid =
                            FirebaseAuth.instance.currentUser?.uid ?? '';
                        final chatService = FirestoreChatService();
                        
                        String doctorId = isDoctor ? user.id : currentUid;
                        String patientId = isDoctor ? currentUid : user.id;

                        await chatService.getOrCreateChat(
                          doctorId: doctorId,
                          patientId: patientId,
                        );

                        if (!context.mounted) return;
                        context.pop();
                      },
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
                  if (!isDoctor && dateOfBirth != null) ...[
                    _buildInfoRow(context, Icons.calendar_today_rounded,
                        "Date of Birth", dateOfBirth!),
                    Divider(height: 1, color: theme.colorScheme.outlineVariant),
                  ],
                  if (!isDoctor && gender != null) ...[
                    _buildInfoRow(context, Icons.person_outline_rounded,
                        "Gender", gender!),
                    Divider(height: 1, color: theme.colorScheme.outlineVariant),
                  ],
                  if (phone != null) ...[
                    _buildInfoRow(
                        context, Icons.phone_rounded, "Phone", phone!),
                    Divider(height: 1, color: theme.colorScheme.outlineVariant),
                  ],
                  if (email != null) ...[
                    _buildInfoRow(
                        context, Icons.email_rounded, "Email", email!),
                    Divider(height: 1, color: theme.colorScheme.outlineVariant),
                  ],
                  if (isDoctor) ...[
                    _buildInfoRow(context, Icons.star_rounded, "Rating", '${user.rating} (${user.reviews} reviews)'),
                    Divider(height: 1, color: theme.colorScheme.outlineVariant),
                    _buildInfoRow(context, Icons.work_history_rounded, "Experience", '${user.experience} years'),
                    Divider(height: 1, color: theme.colorScheme.outlineVariant),
                    _buildInfoRow(context, Icons.local_hospital_rounded, "Hospital", user.hospital ?? 'N/A'),
                  ],
                  if (!isDoctor) ...[
                    _buildInfoRow(context, Icons.verified_user_rounded, "Role",
                        "Patient"),
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
