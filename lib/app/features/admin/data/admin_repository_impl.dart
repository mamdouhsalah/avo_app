// lib/app/features/admin/data/admin_repository_impl.dart
import 'dart:developer';

import 'package:avo_app/app/core/constants/database_paths.dart';
import 'package:avo_app/app/features/admin/data/admin_repository.dart';
import 'package:avo_app/app/features/admin/models/app_log_model.dart';
import 'package:avo_app/app/features/admin/models/pending_approval_model.dart';
import 'package:firebase_database/firebase_database.dart';

class AdminRepositoryImpl implements AdminRepository {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  @override
  Stream<List<AppLogModel>> streamLogs() {
    return _db
        .ref(DatabasePaths.logs)
        .orderByChild('timestamp')
        .onValue
        .map((event) {
      final snap = event.snapshot;
      if (!snap.exists || snap.value == null) return [];

      final List<AppLogModel> logs = [];
      final rawValue = snap.value;

      if (rawValue is Map) {
        rawValue.forEach((key, value) {
          if (value is Map) {
            final data = Map<String, dynamic>.from(value);
            data['id'] = key.toString();
            logs.add(AppLogModel.fromJson(data));
          }
        });
      }

      // ترتيب تنازلي حسب الوقت (الأحدث أولاً)
      logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return logs;
    });
  }

  @override
  Stream<List<PendingApprovalModel>> streamPendingApprovals() {
    return _db
        .ref(DatabasePaths.pendingApprovals)
        .orderByChild('timestamp')
        .onValue
        .map((event) {
      final snap = event.snapshot;
      if (!snap.exists || snap.value == null) return [];

      final List<PendingApprovalModel> approvals = [];
      final rawValue = snap.value;

      if (rawValue is Map) {
        rawValue.forEach((key, value) {
          if (value is Map) {
            final data = Map<String, dynamic>.from(value);
            data['id'] = key.toString();
            approvals.add(PendingApprovalModel.fromJson(data));
          }
        });
      }

      // الأحدث أولاً
      approvals.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return approvals;
    });
  }

  @override
  Future<Map<String, int>> getStats() async {
    final stats = <String, int>{
      DatabasePaths.users: 0,
      DatabasePaths.doctors: 0,
      DatabasePaths.appointments: 0,
      DatabasePaths.logs: 0,
      DatabasePaths.pendingApprovals: 0,
    };
    try {
      // 1. Get users and doctors count from the users node based on role
      final usersSnap = await _db.ref(DatabasePaths.users).get();
      int patientsCount = 0;
      int doctorsCount = 0;
      
      if (usersSnap.exists && usersSnap.value != null) {
        final val = usersSnap.value;
        if (val is Map) {
          for (var user in val.values) {
            if (user is Map) {
              final role = user['role']?.toString().toLowerCase();
              if (role == 'doctor') {
                doctorsCount++;
              } else if (role != 'admin' && role != 'pharmacy_specialist' && role != 'pharmacy') {
                patientsCount++;
              }
            }
          }
        }
      }
      stats[DatabasePaths.users] = patientsCount;
      stats[DatabasePaths.doctors] = doctorsCount;

      // 2. Count appointments, logs, and pending approvals
      final otherPaths = [
        DatabasePaths.appointments,
        DatabasePaths.logs,
        DatabasePaths.pendingApprovals,
      ];

      for (final path in otherPaths) {
        final snap = await _db.ref(path).get();
        int count = 0;
        if (snap.exists && snap.value != null) {
          final val = snap.value;
          if (val is Map) {
            count = val.length;
          } else if (val is List) {
            count = val.where((e) => e != null).length;
          }
        }
        stats[path] = count;
      }
    } catch (e) {
      log('[AdminRepo] getStats error: $e');
    }
    return stats;
  }

  @override
  Stream<Map<String, int>> streamStats() async* {
    yield await getStats();
    await for (final _ in Stream.periodic(const Duration(seconds: 10))) {
      yield await getStats();
    }
  }

  @override
  Future<void> approveUser({
    required String approvalId,
    required String userId,
    required String email,
    required String role,
  }) async {
    try {
      // Update request status
      await _db
          .ref('${DatabasePaths.pendingApprovals}/$approvalId')
          .update({'status': 'approved'});

      // Update isVerified & is_verified in user node
      await _db.ref('${DatabasePaths.users}/$userId').update({
        'isVerified': true,
        'is_verified': true,
        'role': role,
      });

      log('[AdminRepo] Approved user: $email ($role)');
    } catch (e) {
      log('[AdminRepo] approveUser error: $e');
      rethrow;
    }
  }

  @override
  Future<void> rejectUser({
    required String approvalId,
    required String userId,
    required String email,
  }) async {
    try {
      // Update request status
      await _db
          .ref('${DatabasePaths.pendingApprovals}/$approvalId')
          .update({'status': 'rejected'});

      // Update isVerified & is_verified in user node
      await _db
          .ref('${DatabasePaths.users}/$userId')
          .update({
        'isVerified': false,
        'is_verified': false,
      });

      log('[AdminRepo] Rejected user: $email');
    } catch (e) {
      log('[AdminRepo] rejectUser error: $e');
      rethrow;
    }
  }
}
