import 'dart:developer';

import 'package:avo_app/app/core/errors/database_exception.dart';
import 'package:avo_app/app/core/services/local/hive_models.dart';
import 'package:avo_app/app/core/services/local/hive_service.dart';
import 'package:avo_app/app/core/services/remote/firebase_consumer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:avo_app/app/features/reminder/data/reminder_model.dart';
import 'package:avo_app/app/features/reminder/data/medication_log_repository.dart';
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
  final LogRepository logRepository;

  ReminderCubit({
    required this.firebaseConsumer,
    required this.logRepository,
  }) : super(ReminderInitial());

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

      // Collect Hive keys for meds already marked "took" or "taken" or "skipped" today
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      final todayLogs = logBox.values
          .where((log) =>
              log.actionDate.isAfter(todayStart) &&
              log.actionDate.isBefore(todayEnd) &&
              (log.status == 'taken' || log.status == 'skipped' || log.action == 'took' || log.action == 'skipped'))
          .toList();

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
          String status = 'upcoming';
          final logForThisTime = todayLogs.where((log) => log.medicationKey == hiveKey && (log.scheduledTime == timeStr || log.scheduledTime.isEmpty)).firstOrNull;

          if (logForThisTime != null) {
            status = logForThisTime.status == 'taken' || logForThisTime.action == 'took' ? 'taken' : 'skipped';
          } else if (medMinutes <= currentMinutes) {
            status = 'overdue'; // time passed but not taken
          }

          schedule.add(ReminderModel(
            id: hiveKey.toString(),
            name: med.name,
            dosage: '${med.dose} ${med.unit}',
            pillCount: '${med.dose} ${med.unit}',
            time: '$h:$m $ampm', // Wait, the original timeStr is HH:mm. Let's keep original format available if needed.
            status: status,
            frequency: med.days.length == 7 ? 'يومياً' : '${med.days.length} أيام/أسبوع',
            isActive: status != 'taken' && status != 'skipped',
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

  String _convertTo24Hour(String timeStr) {
    try {
      final parts = timeStr.split(' ');
      if (parts.length != 2) return timeStr;
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      final int min = int.parse(timeParts[1]);
      if (parts[1] == 'PM' && hour != 12) hour += 12;
      if (parts[1] == 'AM' && hour == 12) hour = 0;
      return '${hour.toString().padLeft(2, '0')}:${min.toString().padLeft(2, '0')}';
    } catch (e) {
      return timeStr;
    }
  }

  Future<void> _recordAction(ReminderModel reminder, String status) async {
    final hiveKey = int.tryParse(reminder.id);
    if (hiveKey == null) return;

    try {
      final settingsBox = Hive.box('settings');
      final firebaseKey = settingsBox.get('firebase_key_$hiveKey') as String? ?? '';

      final logEntry = MedicationLog(
        logId: '',
        medicationKey: hiveKey,
        medicationId: firebaseKey,
        medicationName: reminder.name,
        actionDate: DateTime.now(),
        scheduledTime: _convertTo24Hour(reminder.time),
        status: status,
        action: status,
        timestamp: DateTime.now(),
        notificationId: 0,
      );

      await logRepository.saveLog(logEntry);
      loadTodaysMedications(); // refresh state
    } catch (e) {
      log('ReminderCubit._recordAction error: $e');
    }
  }

  /// Logs a dose as taken
  Future<void> markAsTaken(ReminderModel reminder) async {
    await _recordAction(reminder, 'taken');
  }

  /// Logs a dose as skipped
  Future<void> markAsSkipped(ReminderModel reminder) async {
    await _recordAction(reminder, 'skipped');
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
          final uid = FirebaseAuth.instance.currentUser?.uid;
          final path = uid != null ? 'users/$uid/medications/$firebaseKey' : 'medications/$firebaseKey';
          await firebaseConsumer.delete(path);
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