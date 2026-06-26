import 'dart:developer';

import 'package:avo_app/app/core/services/local/hive_models.dart';
import 'package:avo_app/app/core/services/local/hive_service.dart';
import 'package:avo_app/app/core/services/remote/firebase_consumer.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LogRepository {
  final FirebaseConsumer firebaseConsumer;

  LogRepository({required this.firebaseConsumer});

  /// Saves a medication log locally to Hive and attempts to sync it to Firebase.
  /// If Firebase succeeds, the local record is marked as synced.
  Future<void> saveLog(MedicationLog logEntry) async {
    try {
      final logBox = HiveService.getMedicationLogBox();

      // Ensure logId is unique if not provided
      if (logEntry.logId.isEmpty) {
        logEntry.logId = DateTime.now().millisecondsSinceEpoch.toString();
      }

      // 1. Save locally first (Offline-First approach)
      await logBox.put(logEntry.logId, logEntry);

      // 2. Attempt remote sync
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        log('LogRepository: User not logged in, keeping log locally.');
        return;
      }

      final path = 'users/$uid/medication_logs';

      // Push to Firebase
      final response = await firebaseConsumer.push(
        path,
        data: {
          'medicationId': logEntry.medicationId,
          'medicationName': logEntry.medicationName,
          'actionDate': logEntry.actionDate.toIso8601String(),
          'scheduledTime': logEntry.scheduledTime,
          'status': logEntry.status,
          'createdAt': DateTime.now().toIso8601String(),
        },
      );

      // If push succeeded, update the local log's ID to match Firebase
      // and mark as synced
      if (response.isNotEmpty) {
        // Delete the temporary local ID
        await logBox.delete(logEntry.logId);
        
        // Update to Firebase Key and mark synced
        logEntry.logId = response;
        logEntry.isSynced = true;

        // Resave with the real Firebase key
        await logBox.put(logEntry.logId, logEntry);
        log('LogRepository: Log synced successfully with ID: ${logEntry.logId}');
      }
    } catch (e) {
      log('LogRepository error (Saved locally only): $e');
      // Already saved locally with isSynced = false, so we are safe
    }
  }

  /// Optional: Method to sync pending offline logs when internet is restored
  Future<void> syncPendingLogs() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final logBox = HiveService.getMedicationLogBox();
      final pendingLogs = logBox.values.where((log) => !log.isSynced).toList();

      for (var logEntry in pendingLogs) {
        final path = 'users/$uid/medication_logs';
        final response = await firebaseConsumer.push(
          path,
          data: {
            'medicationId': logEntry.medicationId,
            'medicationName': logEntry.medicationName,
            'actionDate': logEntry.actionDate.toIso8601String(),
            'scheduledTime': logEntry.scheduledTime,
            'status': logEntry.status,
            'createdAt': DateTime.now().toIso8601String(),
          },
        );

        if (response.isNotEmpty) {
          await logBox.delete(logEntry.logId);
          logEntry.logId = response;
          logEntry.isSynced = true;
          await logBox.put(logEntry.logId, logEntry);
        }
      }
    } catch (e) {
      log('LogRepository.syncPendingLogs error: $e');
    }
  }
}
