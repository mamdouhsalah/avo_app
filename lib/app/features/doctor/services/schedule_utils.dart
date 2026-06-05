import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ScheduleUtils {
  /// Get event color based on index
  static Color getEventColor(int index) {
    final colors = [
      Colors.blue.withValues(alpha: 0.2),
      Colors.teal.withValues(alpha: 0.2),
      Colors.purple.withValues(alpha: 0.2),
      Colors.orange.withValues(alpha: 0.2),
      Colors.pink.withValues(alpha: 0.2),
    ];
    return colors[index % colors.length];
  }

  /// Get event border color based on index
  static Color getEventBorderColor(int index) {
    final colors = [
      Colors.blue,
      Colors.teal,
      Colors.purple,
      Colors.orange,
      Colors.pink,
    ];
    return colors[index % colors.length];
  }

  /// Format date range
  static String formatDateRange(DateTime start, DateTime end) {
    String startStr = DateFormat('MMM dd').format(start);
    String endStr = DateFormat('dd').format(end);
    return '$startStr - $endStr';
  }

  /// Format month year
  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  /// Format month only
  static String formatMonth(DateTime date) {
    return DateFormat('MMMM').format(date);
  }

  /// Format time range
  static String formatTimeRange(TimeOfDay start, TimeOfDay end) {
    return '${formatTime(start)} - ${formatTime(end)}';
  }

  /// Format day name
  static String formatDayName(DateTime date) {
    return DateFormat('EEE').format(date);
  }

  /// Format full day name
  static String formatFullDayName(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  /// Format time
  static String formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Format appointment date
  static String formatAppointmentDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  /// Format appointment time
  static String formatAppointmentTime(DateTime date, TimeOfDay time) {
    return '${DateFormat('MMM dd').format(date)} ${formatTime(time)}';
  }

  /// Format short date
  static String formatShortDate(DateTime date) {
    return DateFormat('MMM dd').format(date);
  }
}
