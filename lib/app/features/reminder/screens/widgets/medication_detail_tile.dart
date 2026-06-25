import 'dart:ui' as ui;

import 'package:avo_app/app/core/constants/app_spacing.dart';
import 'package:avo_app/app/features/reminder/data/reminder_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/Language/locale_keys.g.dart';

/// A detailed medication tile shown in [ScheduleScreen].
///
/// Supports:
/// - Swipe **left** → delete medication
/// - Tap "Taken / Take" badge → mark as taken
class MedicationDetailTile extends StatelessWidget {
  final ReminderModel reminder;

  /// Called when the user marks the dose as taken.
  final VoidCallback? onMarkTaken;

  /// Called when the user deletes the medication.
  final VoidCallback? onDelete;

  const MedicationDetailTile({
    super.key,
    required this.reminder,
    this.onMarkTaken,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTaken = reminder.status == 'taken';
    final isOverdue = reminder.status == 'overdue';

    return Dismissible(
      key: ValueKey('detail_${reminder.id}_${reminder.time}'),
      direction: DismissDirection.endToStart, // swipe left only
      background: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.v16),
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(16.r),
        ),
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 22.sp),
            SizedBox(width: 6.w),
            Text('حذف',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      confirmDismiss: (_) async {
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
                          style: TextStyle(
                              color: theme.colorScheme.error))),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) => onDelete?.call(),
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.v16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            // ── Top row: icon + name + status badge ──
            Padding(
              padding: EdgeInsets.all(AppSpacing.h16),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: isTaken
                          ? theme.colorScheme.surfaceContainerHighest
                          : theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(
                      isTaken
                          ? Icons.check_rounded
                          : Icons.medication_rounded,
                      color: isTaken
                          ? Colors.grey
                          : theme.colorScheme.primary,
                      size: 28.sp,
                    ),
                  ),
                  SizedBox(width: AppSpacing.h16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                reminder.name,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isTaken
                                      ? Colors.grey
                                      : theme.colorScheme.onSurface,
                                  decoration: isTaken
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            // Dynamic status badge
                            _StatusBadge(
                              isTaken: isTaken,
                              isOverdue: isOverdue,
                              onMarkTaken: onMarkTaken,
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${reminder.dosage} • ${reminder.pillCount}',
                          style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                          textDirection: ui.TextDirection.ltr,
                        ),
                        SizedBox(height: 8.h),
                        if (reminder.frequency.isNotEmpty)
                          Row(
                            children: [
                              Icon(Icons.repeat_rounded,
                                  size: 14.sp,
                                  color: theme.colorScheme.primary),
                              SizedBox(width: 4.w),
                              Text(
                                reminder.frequency,
                                style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Bottom row: time chip ──
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.h16, vertical: 10.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16.r),
                    bottomRight: Radius.circular(16.r)),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time_rounded,
                      size: 14.sp, color: Colors.grey),
                  SizedBox(width: 6.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20.r)),
                    child: Text(
                      reminder.time,
                      style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold),
                      textDirection: ui.TextDirection.ltr,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Status badge widget ───────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final bool isTaken;
  final bool isOverdue;
  final VoidCallback? onMarkTaken;

  const _StatusBadge({
    required this.isTaken,
    required this.isOverdue,
    this.onMarkTaken,
  });

  @override
  Widget build(BuildContext context) {
    if (isTaken) {
      return _chip(
          label: LocaleKeys.reminder_taken.tr(),
          color: Colors.green,
          context: context);
    }
    if (isOverdue) {
      return GestureDetector(
        onTap: onMarkTaken,
        child: _chip(
            label: 'خذ الآن',
            color: Theme.of(context).colorScheme.error,
            context: context),
      );
    }
    // upcoming / next
    return GestureDetector(
      onTap: onMarkTaken,
      child: _chip(
          label: LocaleKeys.reminder_active.tr(),
          color: Colors.green,
          context: context),
    );
  }

  Widget _chip(
      {required String label,
      required Color color,
      required BuildContext context}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 10.sp, fontWeight: FontWeight.bold),
      ),
    );
  }
}