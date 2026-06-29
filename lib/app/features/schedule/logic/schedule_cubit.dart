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
  final LogRepository logRepository;

  ScheduleCubit({
    required this.firebaseConsumer,
    required this.logRepository,
  }) : super(ScheduleInitial());

  /// Loads medications scheduled for [date] and appointments on [date].
  /// Emits [ScheduleLoading] → [ScheduleLoaded] or [ScheduleError].
  void loadForDate(DateTime date) {
    emit(ScheduleLoading());
    _fetchAndEmitLoaded(date);
  }

  /// Refreshes data WITHOUT emitting [ScheduleLoading] first.
  /// ✅ Prevents calendar PageController from receiving competing scroll commands.
  void _refreshSilently(DateTime date) => _fetchAndEmitLoaded(date);

  void _fetchAndEmitLoaded(DateTime date) {
    try {
      // ✅ English day name — matches what AddMedicationCubit now stores
      final dayName = weekdayToEnglish(date.weekday);

      final medBox = HiveService.getMedicationBox();
      final logBox = HiveService.getMedicationLogBox();

      // Hoist box references above loop (Issue 13 fix)
      final dateStart = DateTime(date.year, date.month, date.day);
      final dateEnd = dateStart.add(const Duration(days: 1));
      final dateLogs = logBox.values
          .where((log) =>
              log.actionDate.isAfter(dateStart) &&
              log.actionDate.isBefore(dateEnd) &&
              (log.status == 'taken' ||
                  log.status == 'skipped' ||
                  log.action == 'took' ||
                  log.action == 'skipped'))
          .toList();

      final dateOnly = DateTime(date.year, date.month, date.day);

      final List<ReminderModel> medications = [];
      for (final med in medBox.values) {
        if (!med.days.contains(dayName)) continue;
        
        if (med.fromDate != null) {
          final fromOnly = DateTime(med.fromDate!.year, med.fromDate!.month, med.fromDate!.day);
          if (dateOnly.isBefore(fromOnly)) continue;
        }
        if (med.toDate != null) {
          final toOnly = DateTime(med.toDate!.year, med.toDate!.month, med.toDate!.day);
          if (dateOnly.isAfter(toOnly)) continue;
        }

        for (final timeStr in med.times) {
          final parts = timeStr.split(':');
          if (parts.length < 2) continue;
          final hour = int.tryParse(parts[0]);
          final minute = int.tryParse(parts[1]);
          if (hour == null || minute == null) continue;

          final tod = TimeOfDay(hour: hour, minute: minute);
          final h = tod.hourOfPeriod == 0 ? 12 : tod.hourOfPeriod;
          final m = tod.minute.toString().padLeft(2, '0');
          final ampm = tod.period == DayPeriod.am ? 'AM' : 'PM';

          // ✅ Null-safe hive key access
          final hiveKey = med.key as int?;
          if (hiveKey == null) continue;

          String status = 'upcoming';
          final logForThisTime = dateLogs
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
          }

          final freq = med.days.length == 7
              ? LocaleKeys.reminder_daily_frequency.tr()
              : LocaleKeys.reminder_days_per_week
                  .tr(namedArgs: {'count': '${med.days.length}'});

          medications.add(ReminderModel(
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
      log('ScheduleCubit._fetchAndEmitLoaded error: $e');
      emit(ScheduleError(DatabaseExceptionHandler.handleException(e).message));
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
      final logId = '${DateTime.now().millisecondsSinceEpoch}_$hiveKey';

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

      // Reload for the currently selected date (silently — no loading flash)
      final current = state is ScheduleLoaded
          ? (state as ScheduleLoaded).selectedDate
          : DateTime.now();
      _refreshSilently(current);
    } catch (e) {
      log('ScheduleCubit._recordAction error: $e');
    }
  }

  /// Marks a medication dose as taken
  Future<void> markAsTaken(ReminderModel reminder) async {
    await _recordAction(reminder, 'taken');
  }

  /// Marks a medication dose as skipped
  Future<void> markAsSkipped(ReminderModel reminder) async {
    await _recordAction(reminder, 'skipped');
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
          final uid = FirebaseAuth.instance.currentUser?.uid;
          final path = uid != null ? 'users/$uid/medications/$firebaseKey' : 'medications/$firebaseKey';
          await firebaseConsumer.delete(path);
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

  /// ✅ Bug 2 fix: wrapped in try/catch. Returns 9999 on parse failure.
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
