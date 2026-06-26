import 'dart:developer';

import 'package:avo_app/app/core/services/local/hive_models.dart';
import 'package:avo_app/app/core/services/local/hive_service.dart';
import 'package:avo_app/app/core/services/local/notification_service.dart';
import 'package:avo_app/app/core/services/remote/firebase_consumer.dart';
import 'package:avo_app/app/core/utils/day_localizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

// ─────────────────────────── States ───────────────────────────

abstract class AddMedicationState {}

class AddMedicationInitial extends AddMedicationState {}

class AddMedicationLoading extends AddMedicationState {}

class AddMedicationSuccess extends AddMedicationState {}

class AddMedicationError extends AddMedicationState {
  final String error;
  AddMedicationError(this.error);
}

// ─────────────────────────── Cubit ────────────────────────────

class AddMedicationCubit extends Cubit<AddMedicationState> {
  final FirebaseConsumer firebaseConsumer;

  AddMedicationCubit({required this.firebaseConsumer})
      : super(AddMedicationInitial());

  Future<void> addMedication({
    required String name,
    required TimeOfDay time,
    required DateTime? fromDate,
    required DateTime? toDate,
    required String frequency,
    required bool soundEnabled,
  }) async {
    emit(AddMedicationLoading());

    try {
      final timeString =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      // ✅ Pass fromDate so Weekly/Custom can determine the correct day
      final List<String> days = _getDaysList(frequency, fromDate);

      final newMedication = Medication(
        name: name,
        dose: 1.0,
        unit: 'pill', // ✅ English key — displayed via tr(LocaleKeys.reminder_pill)
        times: [timeString],
        days: days,
        instructions: '',
        fromDate: fromDate,
        toDate: toDate,
      );

      // 1. Save locally to Hive — box.add() returns the auto-generated int key
      final medBox = HiveService.getMedicationBox();
      final int hiveKey = await medBox.add(newMedication);

      // 2. Schedule the local notification
      await NotificationService.scheduleMedicationNotification(
          newMedication, timeString, 0);

      // 3. Push to Firebase and get the remote key
      final uid = FirebaseAuth.instance.currentUser?.uid;
      final path = uid != null ? 'users/$uid/medications' : 'medications';
      
      final String firebaseKey = await firebaseConsumer.push(
        path,
        data: {
          'name': name,
          'dose': 1.0,
          'unit': 'pill', // ✅ English key in Firebase too
          'times': [timeString],
          'days': days, // ✅ English day names: ['Saturday', 'Sunday', ...]
          'frequency': frequency,
          'soundEnabled': soundEnabled,
          'fromDate': fromDate?.toIso8601String(),
          'toDate': toDate?.toIso8601String(),
          'createdAt': DateTime.now().toIso8601String(),
        },
      );

      // 4. Persist hiveKey → firebaseKey mapping in the settings box so that
      //    ReminderCubit and ScheduleCubit can later delete or update the
      //    Firebase record without needing a separate index.
      final settingsBox = Hive.box('settings');
      await settingsBox.put('firebase_key_$hiveKey', firebaseKey);
      log('AddMedicationCubit: saved mapping hive[$hiveKey] → firebase[$firebaseKey]');

      emit(AddMedicationSuccess());
    } catch (e) {
      emit(AddMedicationError(e.toString()));
    }
  }

  /// Returns the list of English day names to schedule based on [frequency].
  ///
  /// - 'Daily'          → all 7 days
  /// - 'Weekly'/'Custom' → only the day of the week that [fromDate] falls on
  List<String> _getDaysList(String frequency, DateTime? fromDate) {
    if (frequency == 'Weekly' || frequency == 'Custom') {
      final referenceDate = fromDate ?? DateTime.now();
      // ✅ weekdayToEnglish maps DateTime.weekday (1=Mon…7=Sun) → English key
      return [weekdayToEnglish(referenceDate.weekday)];
    }
    // Default: Daily → all 7 days (English keys only)
    return List<String>.from(kAllEnglishDays);
  }
}