import 'package:avo_app/app/core/shared/CustomAvatar.dart';
import 'package:avo_app/app/core/models/patient_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomPatientCard extends StatelessWidget {
  final PatientModel patient;
  final VoidCallback? onTap;

  const CustomPatientCard({
    super.key,
    required this.patient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // ألوان مختلفة لكل مريض
    final flagColors = [
      Colors.purple,
      Colors.orange,
      Colors.blue,
      const Color(0xFF4ECDC4),
      Colors.teal,
    ];
    final flagColor = flagColors[patient.id.hashCode % flagColors.length];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.sp),
        width: double.infinity,
        height: 124.h,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: flagColor.withOpacity(0.3),
            width: 1.2.sp,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            CustomAvatar(
              imageUrl: patient.image,
              size: 52.r,
              borderColor: flagColor,
            ),
            SizedBox(width: 12.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    patient.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    patient.diagnosis ?? patient.email,
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
                      fontSize: 13.5.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Text(
                        patient.phone,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      if (patient.isVerified)
                        Padding(
                          padding: EdgeInsets.only(left: 8.w),
                          child: Icon(Icons.verified, color: Colors.green, size: 18.sp),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // More Options + Flag
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.visibility),
                            title: const Text('View Details'),
                            onTap: () => Navigator.pop(context),
                          ),
                          ListTile(
                            leading: const Icon(Icons.edit),
                            title: const Text('Edit Patient'),
                            onTap: () => Navigator.pop(context),
                          ),
                          ListTile(
                            leading: const Icon(Icons.delete_outline, color: Colors.red),
                            title: const Text('Delete', style: TextStyle(color: Colors.red)),
                            onTap: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.more_vert,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    size: 24.sp,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8.sp),
                  decoration: BoxDecoration(
                    color: flagColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.flag_rounded,
                    color: flagColor,
                    size: 22.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}