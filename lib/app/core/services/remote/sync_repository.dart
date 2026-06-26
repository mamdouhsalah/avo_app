import 'dart:developer';

import 'package:avo_app/app/core/services/local/hive_models.dart';
import 'package:avo_app/app/core/services/local/hive_service.dart';
import 'package:avo_app/app/core/services/remote/firebase_consumer.dart';
import 'package:avo_app/app/core/utils/day_localizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';

class SyncRepository {
  final FirebaseConsumer firebaseConsumer;

  SyncRepository({required this.firebaseConsumer});

  /// Fetches all medications for the currently logged-in user from Firebase
  /// and syncs them to the local Hive database.
  Future<void> syncMedicationsFromRemote() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      log('SyncRepository: Sync aborted, no authenticated user found.');
      return;
    }

    try {
      log('SyncRepository: Starting sync for user $uid');
      
      // 1. Fetch from Firebase (user scoped)
      final medications = await firebaseConsumer.getList(
        'users/$uid/medications',
        fromJson: (json) => json, // Request raw map
      );

      // 2. Clear local Hive medications box to avoid duplicates on initial sync
      final medBox = HiveService.getMedicationBox();
      await medBox.clear();
      
      final settingsBox = Hive.box('settings');
      int syncCount = 0;

      // 3. Save each remote medication to Hive
      for (final medJson in medications) {
        final firebaseKey = medJson['id']; // getList auto-injects the Firebase key as 'id'
        
        // Safely parse data with fallbacks
        final name = medJson['name'] as String? ?? 'غير معروف';
        final dose = (medJson['dose'] as num?)?.toDouble() ?? 1.0;
        final unit = medJson['unit'] as String? ?? 'حبة';
        final times = (medJson['times'] as List<dynamic>?)?.cast<String>() ?? [];
        final rawDays = (medJson['days'] as List<dynamic>?)?.cast<String>() ?? [];
        final days = rawDays.map((d) => mapDayToEnglish(d)).toList();

        DateTime? fromDate;
        if (medJson['fromDate'] != null) {
          fromDate = DateTime.tryParse(medJson['fromDate'].toString());
        }

        DateTime? toDate;
        if (medJson['toDate'] != null) {
          toDate = DateTime.tryParse(medJson['toDate'].toString());
        }
        
        final newMedication = Medication(
          name: name,
          dose: dose,
          unit: unit,
          times: times,
          days: days,
          instructions: '',
          fromDate: fromDate,
          toDate: toDate,
        );

        // Save to Hive and get the auto-incremented local key
        final int hiveKey = await medBox.add(newMedication);

        // Persist mapping so local edits/deletes know which remote record to target
        await settingsBox.put('firebase_key_$hiveKey', firebaseKey);
        
        syncCount++;
      }
      
      log('SyncRepository: Successfully synced $syncCount medications from remote for user $uid.');

    } catch (e) {
      // Gracefully handle failures (e.g., no internet, timeout) so the app doesn't crash on login
      log('SyncRepository error: $e');
    }
  }
}
