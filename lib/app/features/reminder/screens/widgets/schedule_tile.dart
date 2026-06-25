import 'dart:ui' as ui;

import 'package:avo_app/app/core/constants/app_spacing.dart';
import 'package:avo_app/app/features/reminder/data/reminder_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/Language/locale_keys.g.dart';

/// A compact tile shown in the Today's Schedule list on [ReminderScreen].
///
/// Supports:
/// - Swipe **right** → mark as taken
/// - Swipe **left**  → delete medication
/// - "Take" button (visible on the 'next' dose) → mark as taken
class ScheduleTile extends StatelessWidget {
  final ReminderModel reminder;

  /// Called when the user marks this dose as taken.
  final VoidCallback? onMarkTaken;

  /// Called when the user deletes this medication.
  final VoidCallback? onDelete;

  const ScheduleTile({
    super.key,
    required this.reminder,
    this.onMarkTaken,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTaken = reminder.status == 'taken';
    final isNext = reminder.status == 'next';
    final isOverdue = reminder.status == 'overdue';

    return Dismissible(
      key: ValueKey('${reminder.id}_${reminder.time}'),
      // Swipe right → mark as taken
      background: _buildSwipeBackground(
        context,
        alignment: Alignment.centerLeft,
        color: Colors.green.shade400,
        icon: Icons.check_circle_outline_rounded,
        label: LocaleKeys.reminder_take.tr(),
      ),
      // Swipe left → delete
      secondaryBackground: _buildSwipeBackground(
        context,
        alignment: Alignment.centerRight,
        color: theme.colorScheme.error,
        icon: Icons.delete_outline_rounded,
        label: 'حذف',
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Mark as taken — no actual dismiss (tile updates in place via reload)
          onMarkTaken?.call();
          return false;
        } else {
          // Delete — confirm then remove
          return await _confirmDelete(context);
        }
      },
      onDismissed: (_) => onDelete?.call(),
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.v12),
        padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.h16, vertical: AppSpacing.v16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isNext
                ? theme.colorScheme.primary.withValues(alpha: 0.4)
                : isOverdue
                    ? theme.colorScheme.error.withValues(alpha: 0.3)
                    : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: isNext ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            // ── Leading icon ──
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: isTaken
                    ? theme.colorScheme.surfaceContainerHighest
                    : isOverdue
                        ? theme.colorScheme.error.withValues(alpha: 0.1)
                        : theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                isTaken
                    ? Icons.check_rounded
                    : isOverdue
                        ? Icons.warning_amber_rounded
                        : Icons.medication_rounded,
                color: isTaken
                    ? Colors.grey
                    : isOverdue
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                size: 24.sp,
              ),
            ),

            SizedBox(width: AppSpacing.h16),

            // ── Name + dosage & time ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color:
                          isTaken ? Colors.grey : theme.colorScheme.onSurface,
                      decoration: isTaken ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${reminder.dosage} • ${reminder.time}',
                    textDirection: ui.TextDirection.ltr,
                    style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // ── Trailing label / Take button ──
            if (isNext)
              ElevatedButton(
                onPressed: onMarkTaken,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.h12, vertical: 6.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                  minimumSize: Size(60.w, 32.h),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  LocaleKeys.reminder_take.tr(),
                  style: TextStyle(
                    inherit: false,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              )
            else if (isTaken)
              Text(
                LocaleKeys.reminder_taken.tr(),
                style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              )
            else if (isOverdue)
              Text(
                'متأخر',
                style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.error),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(
    BuildContext context, {
    required AlignmentGeometry alignment,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.v12),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16.r),
      ),
      alignment: alignment,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 22.sp),
          SizedBox(width: 6.w),
          Text(label,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('حذف الدواء'),
            content: Text('هل تريد حذف "${reminder.name}" نهائياً؟'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('إلغاء')),
              TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text('حذف',
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error))),
            ],
          ),
        ) ??
        false;
  }
}