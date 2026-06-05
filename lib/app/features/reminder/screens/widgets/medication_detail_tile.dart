import 'package:avo_app/app/core/constants/app_spacing.dart';
import 'package:avo_app/app/features/reminder/data/reminder_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MedicationDetailTile extends StatelessWidget {
  final ReminderModel reminder;

  const MedicationDetailTile({super.key, required this.reminder});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.v16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: theme.colorScheme.shadow.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(AppSpacing.h16),
            child: Row(
              children: [
                // أيقونة الدواء الملونة
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(Icons.medication_rounded, color: theme.colorScheme.primary, size: 28.sp),
                ),
                SizedBox(width: AppSpacing.h16),
                // بيانات الدواء
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(reminder.name, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                          // Badge الحالة (Active)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text("Active", style: TextStyle(color: Colors.green, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text("${reminder.dosage} • ${reminder.pillCount}",
                          style: TextStyle(color: Colors.grey, fontSize: 13.sp)),
                      SizedBox(height: 8.h),
                      // صف التردد
                      Row(
                        children: [
                          Icon(Icons.repeat_rounded, size: 14.sp, color: theme.colorScheme.primary),
                          SizedBox(width: 4.w),
                          Text(reminder.frequency, style: TextStyle(color: theme.colorScheme.primary, fontSize: 12.sp, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // شريط الوقت السفلي
          Container(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.h16, vertical: 10.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16.r), bottomRight: Radius.circular(16.r)),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time_rounded, size: 14.sp, color: Colors.grey),
                SizedBox(width: 6.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha:0.1), borderRadius: BorderRadius.circular(20.r)),
                  child: Text(reminder.time, style: TextStyle(color: theme.colorScheme.primary, fontSize: 12.sp, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}