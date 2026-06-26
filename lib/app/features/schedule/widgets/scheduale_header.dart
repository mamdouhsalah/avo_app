import 'package:avo_app/app/core/constants/app_imgs.dart';
import 'package:avo_app/app/core/utils/day_localizer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/Language/locale_keys.g.dart';

/// Header row shown at the top of [ScheduleScreen].
///
/// Displays the real [selectedDate] formatted as a human-readable
/// Arabic day name + numeric date, and a decorative avatar.
class ScheduleHeader extends StatelessWidget {
  /// The date currently selected in the calendar.
  final DateTime selectedDate;

  const ScheduleHeader({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isToday = _isSameDay(selectedDate, DateTime.now());
    // ✅ Locale-aware day/month names via day_localizer.dart
    final dayLabel = isToday
        ? LocaleKeys.schedule_today_label.tr()
        : translateDay(weekdayToEnglish(selectedDate.weekday));
    final dateLabel =
        '${selectedDate.day} ${translateMonth(selectedDate.month)} ${selectedDate.year}';

    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dayLabel,
              style: TextStyle(
                  fontSize: 12.sp,
                  color: isToday
                      ? colorScheme.primary
                      : Colors.grey,
                  fontWeight: isToday
                      ? FontWeight.w600
                      : FontWeight.normal),
            ),
            SizedBox(height: 4.h),
            Text(
              dateLabel,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15.sp,
                  color: colorScheme.onSurface),
            ),
          ],
        ),
        const Spacer(),
        Container(
          width: 55.w,
          height: 55.h,
          decoration: BoxDecoration(
            border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.4),
                width: 1.5.w),
            borderRadius: BorderRadius.circular(200.r),
          ),
          child: CircleAvatar(
            radius: 22.r,
            backgroundImage: const AssetImage(AppImgs.doctor),
          ),
        ),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}