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
class MedicationDetailTile extends StatefulWidget {
  final ReminderModel reminder;

  /// Called when the user marks the dose as taken.
  final VoidCallback? onMarkTaken;

  /// Called when the user marks the dose as skipped.
  final VoidCallback? onMarkSkipped;

  /// Called when the user deletes the medication.
  final VoidCallback? onDelete;

  const MedicationDetailTile({
    super.key,
    required this.reminder,
    this.onMarkTaken,
    this.onMarkSkipped,
    this.onDelete,
  });

  @override
  State<MedicationDetailTile> createState() => _MedicationDetailTileState();
}

class _MedicationDetailTileState extends State<MedicationDetailTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final theme = Theme.of(context);
    _colorAnimation = ColorTween(
      begin: theme.colorScheme.surface,
      end: theme.colorScheme.error.withValues(alpha: 0.2),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTaken = widget.reminder.status == 'taken';
    final isSkipped = widget.reminder.status == 'skipped';
    final isOverdue = widget.reminder.status == 'overdue';

    return Dismissible(
      key: ValueKey('detail_${widget.reminder.id}_${widget.reminder.time}'),
      // Swipe right → mark as taken
      background: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.v16),
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          color: Colors.green.shade400,
          borderRadius: BorderRadius.circular(16.r),
        ),
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 22.sp),
            SizedBox(width: 6.w),
            Text(LocaleKeys.reminder_take.tr(),
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      // Swipe left → skip
      secondaryBackground: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.v16),
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          color: Colors.orange.shade400,
          borderRadius: BorderRadius.circular(16.r),
        ),
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cancel_outlined, color: Colors.white, size: 22.sp),
            SizedBox(width: 6.w),
            Text(LocaleKeys.reminder_skip_label.tr(),
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          widget.onMarkTaken?.call();
          return false;
        } else {
          widget.onMarkSkipped?.call();
          return false;
        }
      },
      child: GestureDetector(
        onLongPressDown: (_) => _controller.forward(),
        onLongPressCancel: () => _controller.reverse(),
        onLongPressUp: () => _controller.reverse(),
        onLongPress: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(LocaleKeys.reminder_delete_medication_title.tr()),
              content: Text(LocaleKeys.reminder_delete_medication_confirm
                  .tr(namedArgs: {'name': widget.reminder.name})),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text(LocaleKeys.general_cancel.tr())),
                TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text(LocaleKeys.general_delete.tr(),
                        style: TextStyle(color: theme.colorScheme.error))),
              ],
            ),
          ) ?? false;

          if (confirm) {
            widget.onDelete?.call();
          } else {
            _controller.reverse();
          }
        },
        child: AnimatedBuilder(
          animation: _colorAnimation,
          builder: (context, child) {
            return Container(
              margin: EdgeInsets.only(bottom: AppSpacing.v16),
              decoration: BoxDecoration(
                color: _colorAnimation.value,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                      color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: child,
            );
          },
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
                                  widget.reminder.name,
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
                                isSkipped: isSkipped,
                                isOverdue: isOverdue,
                                onMarkTaken: widget.onMarkTaken,
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${widget.reminder.dosage} • ${widget.reminder.pillCount}',
                            style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                            textDirection: ui.TextDirection.ltr,
                          ),
                          SizedBox(height: 8.h),
                          if (widget.reminder.frequency.isNotEmpty)
                            Row(
                              children: [
                                Icon(Icons.repeat_rounded,
                                    size: 14.sp,
                                    color: theme.colorScheme.primary),
                                SizedBox(width: 4.w),
                                Text(
                                  widget.reminder.frequency,
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
                        widget.reminder.time,
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
      ),
    );
  }
}

// ─── Status badge widget ───────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final bool isTaken;
  final bool isSkipped;
  final bool isOverdue;
  final VoidCallback? onMarkTaken;

  const _StatusBadge({
    required this.isTaken,
    required this.isSkipped,
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
    if (isSkipped) {
      return _chip(
          label: LocaleKeys.reminder_skip_label.tr(),
          color: Colors.orange,
          context: context);
    }
    if (isOverdue) {
      return GestureDetector(
        onTap: onMarkTaken,
        child: _chip(
            label: LocaleKeys.schedule_take_now.tr(),
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