import 'dart:ui' as ui;

import 'package:avo_app/app/core/constants/app_spacing.dart';
import 'package:avo_app/app/features/reminder/data/reminder_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/Language/locale_keys.g.dart';

class NextDoseCard extends StatelessWidget {
  /// The next upcoming medication dose loaded from [ReminderCubit].
  final ReminderModel nextDose;

  /// Called when the user taps "Take Now". The caller is responsible
  /// for triggering [ReminderCubit.markAsTaken].
  final VoidCallback? onTake;

  const NextDoseCard({
    super.key,
    required this.nextDose,
    this.onTake,
  });

  /// Calculates how many minutes until the dose time.
  /// Returns a formatted string like "08 min" or "2 h 15 min".
  String _getTimeRemaining() {
    // Parse the time string, e.g. "9:30 AM" or "02:15 PM"
    try {
      final parts = nextDose.time.split(' ');
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      final int minute = int.parse(timeParts[1]);
      if (parts[1] == 'PM' && hour != 12) hour += 12;
      if (parts[1] == 'AM' && hour == 12) hour = 0;

      final now = DateTime.now();
      final doseTime = DateTime(now.year, now.month, now.day, hour, minute);
      final diff = doseTime.difference(now);

      if (diff.isNegative) return '—';
      if (diff.inHours >= 1) {
        return '${diff.inHours} h ${diff.inMinutes % 60} min';
      }
      return '${diff.inMinutes.toString().padLeft(2, '0')} min';
    } catch (_) {
      return '—';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeRemaining = _getTimeRemaining();

    return Container(
      padding: EdgeInsets.all(AppSpacing.h20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: countdown + icon ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocaleKeys.reminder_next_dose_in.tr(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    timeRemaining,
                    textDirection: ui.TextDirection.ltr,
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              CircleAvatar(
                radius: 24.r,
                backgroundColor:
                    theme.colorScheme.primary.withValues(alpha: 0.1),
                child: Icon(Icons.medication_rounded,
                    size: 28.sp, color: theme.colorScheme.primary),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.v20),

          // ── Medication details + Take button ──
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nextDose.name,
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${nextDose.dosage} • ${nextDose.time}',
                      textDirection: ui.TextDirection.ltr,
                      style: TextStyle(
                          fontSize: 13.sp,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: onTake,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  minimumSize: Size(100.w, 40.h),
                  padding:
                      EdgeInsets.symmetric(horizontal: AppSpacing.h16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                ),
                child: Text(
                  LocaleKeys.reminder_take.tr(),
                  style: TextStyle(
                    inherit: false,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}