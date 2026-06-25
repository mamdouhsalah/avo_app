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

abstract class ReminderState {}

class ReminderInitial extends ReminderState {}

class ReminderLoading extends ReminderState {}

class ReminderLoaded extends ReminderState {
  final List<ReminderModel> todaysSchedule;
  final ReminderModel? nextDose;

  ReminderLoaded({required this.todaysSchedule, this.nextDose});
}

class ReminderError extends ReminderState {
  final String error;
  ReminderError(this.error);
}

// ─────────────────────────── Cubit ────────────────────────────

class ReminderCubit extends Cubit<ReminderState> {
  final FirebaseConsumer firebaseConsumer;

  ReminderCubit({required this.firebaseConsumer}) : super(ReminderInitial());

  /// Loads all medications scheduled for today.
  /// Uses [MedicationLog] to determine the real taken/upcoming status
  /// instead of a pure time-based heuristic.
  void loadTodaysMedications() {
    emit(ReminderLoading());
    try {
      final medBox = HiveService.getMedicationBox();
      final logBox = HiveService.getMedicationLogBox();

      // Arabic day name matching what AddMedicationCubit stores
      final arabicDays = {
        1: 'الإثنين',
        2: 'الثلاثاء',
        3: 'الأربعاء',
        4: 'الخميس',
        5: 'الجمعة',
        6: 'السبت',
        7: 'الأحد',
      };
      final todayName = arabicDays[DateTime.now().weekday];

      // Collect Hive keys for meds already marked "took" today
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      final takenKeys = logBox.values
          .where((log) =>
              log.timestamp.isAfter(todayStart) &&
              log.timestamp.isBefore(todayEnd) &&
              log.action == 'took')
          .map((log) => log.medicationKey)
          .toSet();

      final currentMinutes = TimeOfDay.now().hour * 60 + TimeOfDay.now().minute;

      List<ReminderModel> schedule = [];

      for (final med in medBox.values) {
        if (!med.days.contains(todayName)) continue;

        for (final timeStr in med.times) {
          final parts = timeStr.split(':');
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);
          final medMinutes = hour * 60 + minute;

          final tod = TimeOfDay(hour: hour, minute: minute);
          final h = tod.hourOfPeriod == 0 ? 12 : tod.hourOfPeriod;
          final m = tod.minute.toString().padLeft(2, '0');
          final ampm = tod.period == DayPeriod.am ? 'AM' : 'PM';

          final hiveKey = med.key as int;

          // Real status: check MedicationLog first, then fall back to time
          String status;
          if (takenKeys.contains(hiveKey)) {
            status = 'taken';
          } else if (medMinutes <= currentMinutes) {
            status = 'overdue'; // time passed but not taken
          } else {
            status = 'upcoming';
          }

          schedule.add(ReminderModel(
            id: hiveKey.toString(),
            name: med.name,
            dosage: '${med.dose} ${med.unit}',
            pillCount: '${med.dose} ${med.unit}',
            time: '$h:$m $ampm',
            status: status,
            frequency: med.days.length == 7 ? 'يومياً' : '${med.days.length} أيام/أسبوع',
            isActive: !takenKeys.contains(hiveKey),
          ));
        }
      }

      // Sort by time ascending
      schedule.sort((a, b) =>
          _parseTimeMinutes(a.time).compareTo(_parseTimeMinutes(b.time)));

      // Mark the first upcoming/overdue dose as 'next'
      ReminderModel? nextDose;
      for (int i = 0; i < schedule.length; i++) {
        if (schedule[i].status == 'upcoming' || schedule[i].status == 'overdue') {
          schedule[i] = schedule[i].copyWith(status: 'next');
          nextDose = schedule[i];
          break;
        }
      }

      emit(ReminderLoaded(todaysSchedule: schedule, nextDose: nextDose));
    } catch (e) {
      log('ReminderCubit.loadTodaysMedications error: $e');
      emit(ReminderError(DatabaseExceptionHandler.handleException(e).message));
    }
  }

  /// Logs a dose as taken in [MedicationLog] and reloads the schedule.
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
      loadTodaysMedications(); // refresh state
    } catch (e) {
      log('ReminderCubit.markAsTaken error: $e');
    }
  }

  /// Deletes the medication from Hive, then best-effort syncs the delete
  /// to Firebase using the key mapping stored in the Hive settings box.
  Future<void> deleteMedication(ReminderModel reminder) async {
    final hiveKey = int.tryParse(reminder.id);
    if (hiveKey == null) return;

    try {
      // 1. Local delete from Hive medications box
      final medBox = HiveService.getMedicationBox();
      await medBox.delete(hiveKey);

      // 2. Best-effort Firebase delete using stored hiveKey → firebaseKey mapping
      final settingsBox = Hive.box('settings');
      final firebaseKey = settingsBox.get('firebase_key_$hiveKey') as String?;
      if (firebaseKey != null) {
        try {
          await firebaseConsumer.delete('medications/$firebaseKey');
          await settingsBox.delete('firebase_key_$hiveKey');
          log('ReminderCubit: Firebase delete succeeded for key $firebaseKey');
        } catch (e) {
          // Non-fatal — local delete already happened
          log('ReminderCubit: Firebase delete failed (best effort): $e');
        }
      }

      // 3. Refresh UI
      loadTodaysMedications();
    } catch (e) {
      log('ReminderCubit.deleteMedication error: $e');
      emit(ReminderError(DatabaseExceptionHandler.handleException(e).message));
    }
  }

  // ─── Helpers ───

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