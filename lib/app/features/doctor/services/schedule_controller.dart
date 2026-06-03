import 'package:flutter/material.dart';
import 'package:avo_app/app/features/doctor/data/data.dart';
import 'package:avo_app/app/core/models/appointment_model.dart';

class ScheduleController {
  /// Get week start date from any date
  static DateTime getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  /// Get week end date
  static DateTime getWeekEnd(DateTime date) {
    return getWeekStart(date).add(const Duration(days: 6));
  }

  /// Get appointments for specific date
  static List<AppointmentModel> getAppointmentsForDate(DateTime date) {
    return DataRepository.appointments.where((apt) {
      return apt.date.year == date.year &&
          apt.date.month == date.month &&
          apt.date.day == date.day;
    }).toList()
      ..sort((a, b) => a.timeRange.start.hour.compareTo(b.timeRange.start.hour));
  }

  /// Get all appointments for entire week
  static List<AppointmentModel> getAppointmentsForWeek(DateTime weekStart) {
    List<AppointmentModel> weekAppointments = [];
    for (int i = 0; i < 7; i++) {
      DateTime date = weekStart.add(Duration(days: i));
      weekAppointments.addAll(getAppointmentsForDate(date));
    }
    return weekAppointments;
  }

  /// Get all appointments for entire month
  static List<AppointmentModel> getAppointmentsForMonth(DateTime date) {
    return DataRepository.appointments.where((apt) {
      return apt.date.year == date.year && apt.date.month == date.month;
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Check if date has appointments
  static bool hasAppointmentsOnDate(DateTime date) {
    return getAppointmentsForDate(date).isNotEmpty;
  }

  /// Get appointments for today
  static List<AppointmentModel> getTodayAppointments() {
    return getAppointmentsForDate(DateTime.now());
  }

  /// Get upcoming appointments (next 7 days)
  static List<AppointmentModel> getUpcomingAppointments({int days = 7}) {
    List<AppointmentModel> upcoming = [];
    DateTime now = DateTime.now();
    for (int i = 0; i < days; i++) {
      DateTime date = now.add(Duration(days: i));
      upcoming.addAll(getAppointmentsForDate(date));
    }
    return upcoming;
  }

  /// Calculate position of event in timeline
  /// Returns top position in logical units (0-480 for 9:00-19:00)
  static double calculateEventPosition(TimeOfDay time, {int startHour = 9}) {
    return ((time.hour - startHour) * 48.0) + ((time.minute / 60) * 48.0);
  }

  /// Get day name from date
  static String getDayName(DateTime date) {
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[date.weekday % 7];
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Get number of days in month
  static int getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  /// Get first weekday of month (1=Monday, 7=Sunday)
  static int getFirstWeekdayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1).weekday;
  }
}