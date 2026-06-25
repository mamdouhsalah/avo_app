import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';

/// A full-month interactive calendar widget used in [ScheduleScreen].
///
/// Unlike [CalendarStripWidget] (week view), this shows the entire month
/// and allows navigating between months. Tapping a day calls [onDaySelected].
class CalendarSection extends StatelessWidget {
  final DateTime selectedDay;
  final Function(DateTime selectedDay) onDaySelected;

  const CalendarSection({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TableCalendar(
      locale: context.locale.languageCode,

      // Bounds: one year back and one year forward
      firstDay: DateTime.now().subtract(const Duration(days: 365)),
      lastDay: DateTime.now().add(const Duration(days: 365)),
      focusedDay: selectedDay,

      // Full month view (unlike the week-strip on the reminder screen)
      calendarFormat: CalendarFormat.month,
      startingDayOfWeek: StartingDayOfWeek.sunday,
      availableCalendarFormats: const {CalendarFormat.month: ''},

      // Selection
      selectedDayPredicate: (day) => isSameDay(day, selectedDay),
      onDaySelected: (selected, focused) => onDaySelected(selected),

      // Header style — real month + year from the calendar itself
      headerStyle: HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
        titleTextStyle: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
        leftChevronIcon: Icon(Icons.chevron_left,
            color: theme.colorScheme.primary),
        rightChevronIcon: Icon(Icons.chevron_right,
            color: theme.colorScheme.primary),
        headerPadding: EdgeInsets.symmetric(vertical: 8.h),
      ),

      // Day cell styles
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,

        // Selected day
        selectedDecoration: BoxDecoration(
          color: theme.colorScheme.primary,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold),

        // Today (when not selected)
        todayDecoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        todayTextStyle: TextStyle(
            color: theme.colorScheme.primary, fontWeight: FontWeight.bold),

        // Regular days
        defaultTextStyle: TextStyle(
            color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500),
        weekendTextStyle: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
      ),

      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle:
            TextStyle(color: Colors.grey.shade500, fontSize: 12.sp),
        weekendStyle:
            TextStyle(color: Colors.grey.shade500, fontSize: 12.sp),
      ),
    );
  }
}