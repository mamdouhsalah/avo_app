import 'package:flutter/material.dart';
import 'package:avo_app/app/core/models/appointment_model.dart';

class AppointmentStatusHelper {
  /// Returns the color of the current status.
  static Color getColor(String status) {
    switch (status) {
      
      case AppointmentStatus.pending:
        return Colors.amber;

      case AppointmentStatus.confirmed:
        return Colors.teal;

      case AppointmentStatus.completed:
        return Colors.grey;

      case AppointmentStatus.canceled:
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  /// Returns the next status after pressing the action button.
  /// Returns null if no action is available.
  static String? getNextStatus(String status) {
    switch (status) {
      case AppointmentStatus.pending:
        return AppointmentStatus.confirmed;

      case AppointmentStatus.confirmed:
        return AppointmentStatus.completed;

      case AppointmentStatus.completed:
      case AppointmentStatus.canceled:
        return null;

      default:
        return null;
    }
  }
}