import 'package:avo_app/app/core/constants/app_spacing.dart';
import 'package:avo_app/app/features/reminder/data/reminder_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScheduleTile extends StatelessWidget {
  final ReminderModel reminder;

  const ScheduleTile({super.key, required this.reminder});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTaken = reminder.status == 'taken';
    final isNext = reminder.status == 'next';

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.v12),
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.h16, vertical: AppSpacing.v16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: isTaken ? theme.colorScheme.surfaceContainerHighest : theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              isTaken ? Icons.check_rounded : Icons.medication_rounded,
              color: isTaken ? Colors.grey : theme.colorScheme.primary,
              size: 24.sp,
            ),
          ),
          SizedBox(width: AppSpacing.h16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: isTaken ? Colors.grey : theme.colorScheme.onSurface,
                    decoration: isTaken ? TextDecoration.lineThrough : null,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  "${reminder.dosage} • ${reminder.time}",
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          if (isNext)
            Text(
              "Next",
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
            )
          else if (isTaken)
            Text(
              "Taken",
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
        ],
      ),
    );
  }
}