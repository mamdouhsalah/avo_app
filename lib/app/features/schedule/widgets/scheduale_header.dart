import 'package:avo_app/app/core/constants/app_imgs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Header row shown at the top of [ScheduleScreen].
///
/// Displays the real [selectedDate] formatted as a human-readable
/// Arabic day name + numeric date, and a decorative avatar.
class ScheduleHeader extends StatelessWidget {
  /// The date currently selected in the calendar.
  final DateTime selectedDate;

  const ScheduleHeader({super.key, required this.selectedDate});

  /// Maps DateTime.weekday → Arabic day name
  String _arabicDayName(int weekday) {
    const names = {
      1: 'الإثنين',
      2: 'الثلاثاء',
      3: 'الأربعاء',
      4: 'الخميس',
      5: 'الجمعة',
      6: 'السبت',
      7: 'الأحد',
    };
    return names[weekday] ?? '';
  }

  /// Maps month number → Arabic month name
  String _arabicMonthName(int month) {
    const names = {
      1: 'يناير', 2: 'فبراير', 3: 'مارس',
      4: 'أبريل', 5: 'مايو', 6: 'يونيو',
      7: 'يوليو', 8: 'أغسطس', 9: 'سبتمبر',
      10: 'أكتوبر', 11: 'نوفمبر', 12: 'ديسمبر',
    };
    return names[month] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isToday = _isSameDay(selectedDate, DateTime.now());
    final dayLabel =
        isToday ? 'اليوم' : _arabicDayName(selectedDate.weekday);
    final dateLabel =
        '${selectedDate.day} ${_arabicMonthName(selectedDate.month)} ${selectedDate.year}';

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