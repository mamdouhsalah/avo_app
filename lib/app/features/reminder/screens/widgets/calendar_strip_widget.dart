import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarStripWidget extends StatelessWidget {
  final DateTime selectedDay;
  final Function(DateTime) onDaySelected;

  const CalendarStripWidget({super.key, required this.selectedDay, required this.onDaySelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: TableCalendar(
        focusedDay: selectedDay,
        firstDay: DateTime.now().subtract(const Duration(days: 365)),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        calendarFormat: CalendarFormat.week, // عرض أسبوعي فقط زي Figma
        startingDayOfWeek: StartingDayOfWeek.sunday,
        headerVisible: false, // هنخفيه عشان إحنا عاملين Header مخصص
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        onDaySelected: (selected, focused) => onDaySelected(selected),

        // ستايل التقويم ليطابق Figma
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          selectedDecoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(12.r),
          ),
          todayDecoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          todayTextStyle: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
          defaultTextStyle: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500),
          weekendTextStyle: TextStyle(color: theme.colorScheme.onSurface),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(color: Colors.grey, fontSize: 12.sp),
          weekendStyle: TextStyle(color: Colors.grey, fontSize: 12.sp),
        ),
      ),
    );
  }
}