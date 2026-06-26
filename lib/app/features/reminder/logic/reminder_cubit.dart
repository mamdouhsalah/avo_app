import 'dart:developer';

import 'package:avo_app/app/core/errors/database_exception.dart';
import 'package:avo_app/app/core/services/local/hive_models.dart';
import 'package:avo_app/app/core/services/local/hive_service.dart';
import 'package:avo_app/app/core/services/remote/firebase_consumer.dart';
import 'package:avo_app/app/core/utils/day_localizer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:avo_app/app/features/reminder/data/reminder_model.dart';
import 'package:avo_app/app/features/reminder/data/medication_log_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import '../../../core/Language/locale_keys.g.dart';

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
  /// Emits [ReminderLoading] → [ReminderLoaded] or [ReminderError].
  void loadTodaysMedications() {
    emit(ReminderLoading());
    _fetchAndEmitLoaded();
  }

  /// Refreshes data WITHOUT emitting [ReminderLoading] first.
  /// ✅ Bug 6 fix: prevents flashing a spinner mid-swipe animation.
  void _refreshSilently() => _fetchAndEmitLoaded();

  void _fetchAndEmitLoaded() {
    try {
      final medBox = HiveService.getMedicationBox();
      final logBox = HiveService.getMedicationLogBox();

      // ✅ English day name — matches what AddMedicationCubit now stores
      final todayName = weekdayToEnglish(DateTime.now().weekday);

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      final todayLogs = logBox.values
          .where((log) =>
              log.actionDate.isAfter(todayStart) &&
              log.actionDate.isBefore(todayEnd) &&
              (log.status == 'taken' ||
                  log.status == 'skipped' ||
                  log.action == 'took' ||
                  log.action == 'skipped'))
          .toList();

      final currentMinutes =
          TimeOfDay.now().hour * 60 + TimeOfDay.now().minute;

      List<ReminderModel> schedule = [];

      final dateOnly = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

      for (final med in medBox.values) {
        if (!med.days.contains(todayName)) continue;
        
        if (med.fromDate != null) {
          final fromOnly = DateTime(med.fromDate!.year, med.fromDate!.month, med.fromDate!.day);
          if (dateOnly.isBefore(fromOnly)) continue;
        }
        if (med.toDate != null) {
          final toOnly = DateTime(med.toDate!.year, med.toDate!.month, med.toDate!.day);
          if (dateOnly.isAfter(toOnly)) continue;
        }

        for (final timeStr in med.times) {
          final timeStrTrimmed = timeStr.trim().toUpperCase();
          final isPM = timeStrTrimmed.contains('PM');
          final isAM = timeStrTrimmed.contains('AM');
          final cleanTime = timeStrTrimmed.replaceAll('AM', '').replaceAll('PM', '').trim();
          final parts = cleanTime.split(':');
          
          if (parts.length < 2) continue;
          final parsedHour = int.tryParse(parts[0]);
          final minute = int.tryParse(parts[1]);
          if (parsedHour == null || minute == null) continue;
          
          int hour = parsedHour;
          if (isPM && hour != 12) hour += 12;
          if (isAM && hour == 12) hour = 0; // standard 24h internal for elapsed calculation
          
          final medMinutes = hour * 60 + minute;
          
          // Re-format for UI
          final h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
          final m = minute.toString().padLeft(2, '0');
          final ampm = (hour >= 12 && hour < 24) ? 'PM' : 'AM';

          // ✅ Bug 19 fix: null-safe Hive key access
          final hiveKey = med.key as int?;
          if (hiveKey == null) continue;

          String status = 'upcoming';
          final logForThisTime = todayLogs
              .where((log) =>
                  log.medicationKey == hiveKey &&
                  (log.scheduledTime == timeStr ||
                      log.scheduledTime.isEmpty))
              .firstOrNull;

          if (logForThisTime != null) {
            status = (logForThisTime.status == 'taken' ||
                    logForThisTime.action == 'took')
                ? 'taken'
                : 'skipped';
          } else if (medMinutes <= currentMinutes) {
            status = 'overdue';
          }

          // ✅ Localized frequency label (easy_localization works at dart level)
          final freq = med.days.length == 7
              ? LocaleKeys.reminder_daily_frequency.tr()
              : LocaleKeys.reminder_days_per_week
                  .tr(namedArgs: {'count': '${med.days.length}'});

          schedule.add(ReminderModel(
            id: hiveKey.toString(),
            name: med.name,
            dosage: '${med.dose} ${med.unit}',
            pillCount: '${med.dose} ${med.unit}',
            time: '$h:$m $ampm',
            status: status,
            frequency: freq,
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
        if (schedule[i].status == 'upcoming' ||
            schedule[i].status == 'overdue') {
          schedule[i] = schedule[i].copyWith(status: 'next');
          nextDose = schedule[i];
          break;
        }
      }

      emit(ReminderLoaded(todaysSchedule: schedule, nextDose: nextDose));
    } catch (e) {
      log('ReminderCubit._fetchAndEmitLoaded error: $e');
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
      final firebaseKey =
          settingsBox.get('firebase_key_$hiveKey') as String? ?? '';

      // ✅ Bug 3 fix: unique ID generated upfront — never an empty string key
      final logId =
          '${DateTime.now().millisecondsSinceEpoch}_$hiveKey';

      final logEntry = MedicationLog(
        logId: logId,
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
      _refreshSilently(); // ✅ Bug 6 fix: no ReminderLoading flash mid-swipe
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

  /// ✅ Bug 2 fix: wrapped in try/catch. Returns 9999 on parse failure so
  /// malformed time strings sort to the end instead of crashing the cubit.
  int _parseTimeMinutes(String timeStr) {
    try {
      final timeStrTrimmed = timeStr.trim().toUpperCase();
      final isPM = timeStrTrimmed.contains('PM');
      final isAM = timeStrTrimmed.contains('AM');
      final cleanTime = timeStrTrimmed.replaceAll('AM', '').replaceAll('PM', '').trim();
      final parts = cleanTime.split(':');
      if (parts.length < 2) return 9999;
      
      int hour = int.parse(parts[0]);
      final min = int.parse(parts[1]);
      
      if (isPM && hour != 12) hour += 12;
      if (isAM && hour == 12) hour = 24; // 12 AM -> End of day
      if (!isPM && !isAM && hour == 0) hour = 24; // 00:00 -> End of day
      
      return hour * 60 + min;
    } catch (_) {
      return 9999;
    }
  }
}