import 'dart:developer';

import 'package:avo_app/app/core/errors/database_exception.dart';
import 'package:avo_app/app/core/services/local/hive_models.dart';
import 'package:avo_app/app/core/services/local/hive_service.dart';
import 'package:avo_app/app/core/services/remote/firebase_consumer.dart';
import 'package:avo_app/app/features/reminder/data/reminder_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

// ─────────────────────────── States ───────────────────────────

abstract class ScheduleState {}

class ScheduleInitial extends ScheduleState {}

class ScheduleLoading extends ScheduleState {}

class ScheduleLoaded extends ScheduleState {
  final DateTime selectedDate;
  final List<ReminderModel> medications;
  final List<Appointment> appointments;

  ScheduleLoaded({
    required this.selectedDate,
    required this.medications,
    required this.appointments,
  });
}

class ScheduleError extends ScheduleState {
  final String error;
  ScheduleError(this.error);
}

// ─────────────────────────── Cubit ────────────────────────────

class ScheduleCubit extends Cubit<ScheduleState> {
  final FirebaseConsumer firebaseConsumer;

  ScheduleCubit({required this.firebaseConsumer}) : super(ScheduleInitial());

  /// Loads medications scheduled for [date] and appointments on [date].
  /// Checks [MedicationLog] to determine real taken/upcoming status.
  void loadForDate(DateTime date) {
    emit(ScheduleLoading());
    try {
      // Arabic day name mapping (matches what's stored in Hive by AddMedicationCubit)
      final arabicDays = {
        1: 'الإثنين',
        2: 'الثلاثاء',
        3: 'الأربعاء',
        4: 'الخميس',
        5: 'الجمعة',
        6: 'السبت',
        7: 'الأحد',
      };
      final dayName = arabicDays[date.weekday];

      final medBox = HiveService.getMedicationBox();
      final logBox = HiveService.getMedicationLogBox();

      // Collect the Hive keys of medications marked as "took" on the selected date
      final dateStart = DateTime(date.year, date.month, date.day);
      final dateEnd = dateStart.add(const Duration(days: 1));
      final takenKeys = logBox.values
          .where((log) =>
              log.timestamp.isAfter(dateStart) &&
              log.timestamp.isBefore(dateEnd) &&
              log.action == 'took')
          .map((log) => log.medicationKey)
          .toSet();

      // Build ReminderModel list for all meds scheduled on this day
      final List<ReminderModel> medications = [];
      for (final med in medBox.values) {
        if (med.days.contains(dayName)) {
          for (final timeStr in med.times) {
            final parts = timeStr.split(':');
            final hour = int.parse(parts[0]);
            final minute = int.parse(parts[1]);

            final tod = TimeOfDay(hour: hour, minute: minute);
            final h = tod.hourOfPeriod == 0 ? 12 : tod.hourOfPeriod;
            final m = tod.minute.toString().padLeft(2, '0');
            final ampm = tod.period == DayPeriod.am ? 'AM' : 'PM';

            final hiveKey = med.key as int;
            final isTaken = takenKeys.contains(hiveKey);

            medications.add(ReminderModel(
              id: hiveKey.toString(),
              name: med.name,
              dosage: '${med.dose} ${med.unit}',
              pillCount: '${med.dose} ${med.unit}',
              time: '$h:$m $ampm',
              status: isTaken ? 'taken' : 'upcoming',
              frequency: med.days.length == 7 ? 'يومياً' : '${med.days.length} أيام/أسبوع',
              isActive: true,
            ));
          }
        }
      }

      // Sort by time ascending
      medications.sort((a, b) =>
          _parseTimeMinutes(a.time).compareTo(_parseTimeMinutes(b.time)));

      // Appointments for the selected date
      final aptBox = HiveService.getAppointmentBox();
      final appointments = aptBox.values
          .where((apt) => _isSameDay(apt.dateTime, date))
          .toList()
        ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

      emit(ScheduleLoaded(
        selectedDate: date,
        medications: medications,
        appointments: appointments,
      ));
    } catch (e) {
      log('ScheduleCubit.loadForDate error: $e');
      emit(ScheduleError(DatabaseExceptionHandler.handleException(e).message));
    }
  }

  /// Marks a medication dose as taken by logging it in [MedicationLog],
  /// then reloads the current date.
  Future<void> markAsTaken(ReminderModel reminder) async {
    final hiveKey = int.tryParse(reminder.id);
    if (hiveKey == null) return;

    try {
      final logBox = HiveService.getMedicationLogBox();
      await logBox.add(MedicationLog(
        medicationKey: hiveKey,
        timestamp: DateTime.now(),
        action: 'took',
        notificationId: 0,
      ));

      // Reload for the currently selected date
      final current = state is ScheduleLoaded
          ? (state as ScheduleLoaded).selectedDate
          : DateTime.now();
      loadForDate(current);
    } catch (e) {
      log('ScheduleCubit.markAsTaken error: $e');
    }
  }

  /// Deletes the medication from Hive and best-effort syncs the delete
  /// to Firebase using the stored key mapping in the settings box.
  Future<void> deleteMedication(ReminderModel reminder) async {
    final hiveKey = int.tryParse(reminder.id);
    if (hiveKey == null) return;

    try {
      // 1. Delete locally
      final medBox = HiveService.getMedicationBox();
      await medBox.delete(hiveKey);

      // 2. Best-effort Firebase delete using saved key mapping
      final settingsBox = Hive.box('settings');
      final firebaseKey = settingsBox.get('firebase_key_$hiveKey') as String?;
      if (firebaseKey != null) {
        try {
          await firebaseConsumer.delete('medications/$firebaseKey');
          await settingsBox.delete('firebase_key_$hiveKey');
        } catch (e) {
          log('ScheduleCubit: Firebase delete failed (best effort): $e');
        }
      }

      // 3. Reload
      final current = state is ScheduleLoaded
          ? (state as ScheduleLoaded).selectedDate
          : DateTime.now();
      loadForDate(current);
    } catch (e) {
      log('ScheduleCubit.deleteMedication error: $e');
      emit(ScheduleError(DatabaseExceptionHandler.handleException(e).message));
    }
  }

  // ─── Helpers ───

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  int _parseTimeMinutes(String timeStr) {
    // Format: "9:00 AM" or "02:30 PM"
    final parts = timeStr.split(' ');
    final timeParts = parts[0].split(':');
    int hour = int.parse(timeParts[0]);
    final int min = int.parse(timeParts[1]);
    if (parts[1] == 'PM' && hour != 12) hour += 12;
    if (parts[1] == 'AM' && hour == 12) hour = 0;
    return hour * 60 + min;
  }
}
