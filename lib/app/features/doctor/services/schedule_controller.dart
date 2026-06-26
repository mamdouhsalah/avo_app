import 'package:flutter/material.dart';
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
  static List<AppointmentModel> getAppointmentsForDate(DateTime date, List<AppointmentModel> appointments) {
    return appointments.where((apt) {
      final aptDate = apt.dateTime;
      return aptDate.year == date.year &&
          aptDate.month == date.month &&
          aptDate.day == date.day;
    }).toList()
      ..sort((a, b) => a.startHour.compareTo(b.startHour));
  }

  /// Get all appointments for entire week
  static List<AppointmentModel> getAppointmentsForWeek(DateTime weekStart, List<AppointmentModel> appointments) {
    List<AppointmentModel> weekAppointments = [];
    for (int i = 0; i < 7; i++) {
      DateTime date = weekStart.add(Duration(days: i));
      weekAppointments.addAll(getAppointmentsForDate(date, appointments));
    }
    return weekAppointments;
  }

  /// Get all appointments for entire month
  static List<AppointmentModel> getAppointmentsForMonth(DateTime date, List<AppointmentModel> appointments) {
    return appointments.where((apt) {
      final aptDate = apt.dateTime;
      return aptDate.year == date.year && aptDate.month == date.month;
    }).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  /// Check if date has appointments
  static bool hasAppointmentsOnDate(DateTime date, List<AppointmentModel> appointments) {
    return getAppointmentsForDate(date, appointments).isNotEmpty;
  }

  /// Get appointments for today
  static List<AppointmentModel> getTodayAppointments(List<AppointmentModel> appointments) {
    return getAppointmentsForDate(DateTime.now(), appointments);
  }

  /// Get upcoming appointments (next 7 days)
  static List<AppointmentModel> getUpcomingAppointments(List<AppointmentModel> appointments, {int days = 7}) {
    List<AppointmentModel> upcoming = [];
    DateTime now = DateTime.now();
    for (int i = 0; i < days; i++) {
      DateTime date = now.add(Duration(days: i));
      upcoming.addAll(getAppointmentsForDate(date, appointments));
    }
    return upcoming;
  }

  /// Calculate position of event in timeline
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