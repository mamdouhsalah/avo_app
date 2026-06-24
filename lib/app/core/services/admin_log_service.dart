// lib/app/core/services/admin_log_service.dart
import 'dart:developer';

import 'package:avo_app/app/core/constants/database_paths.dart';
import 'package:firebase_database/firebase_database.dart';

class AdminLogService {
  AdminLogService._();
  static final AdminLogService instance = AdminLogService._();

  final FirebaseDatabase _db = FirebaseDatabase.instance;

  Future<void> _writeLog({
    required String type,
    required String userId,
    required String email,
    required String message,
    required String level,
  }) async {
    try {
      final ref = _db.ref(DatabasePaths.logs).push();
      await ref.set({
        'type': type,
        'userId': userId,
        'email': email,
        'message': message,
        'level': level,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      log('[AdminLog] $level - $type: $message');
    } catch (e) {
      log('[AdminLog] Failed to write log: $e');
    }
  }

  Future<void> logUserLogin({
    required String userId,
    required String email,
    required String role,
  }) async {
    await _writeLog(
      type: 'user_login',
      userId: userId,
      email: email,
      message: 'User logged in with role: $role',
      level: 'info',
    );
  }

  Future<void> logUserRegistration({
    required String userId,
    required String email,
    required String fullName,
    required String role,
  }) async {
    await _writeLog(
      type: 'user_registration',
      userId: userId,
      email: email,
      message: 'New user registered: $fullName ($role)',
      level: 'success',
    );
  }

  Future<void> logError({
    required String type,
    required String userId,
    required String email,
    required String error,
  }) async {
    await _writeLog(
      type: type,
      userId: userId,
      email: email,
      message: 'Error: $error',
      level: 'error',
    );
  }

  Future<void> logAction({
    required String type,
    required String userId,
    required String email,
    required String message,
    String level = 'info',
  }) async {
    await _writeLog(
      type: type,
      userId: userId,
      email: email,
      message: message,
      level: level,
    );
  }

  /// يرسل طلب موافقة الأدمن لما يسجل يوزر جديد
  Future<void> sendPendingApproval({
    required String userId,
    required String email,
    required String fullName,
    required String role,
    String? profileImage,
    String? specialization,
  }) async {
    try {
      final ref = _db.ref(DatabasePaths.pendingApprovals).push();
      await ref.set({
        'userId': userId,
        'email': email,
        'fullName': fullName,
        'role': role,
        'status': 'pending',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        if (profileImage != null) 'profileImage': profileImage,
        if (specialization != null) 'specialization': specialization,
      });
      log('[AdminLog] Pending approval sent for $email ($role)');
    } catch (e) {
      log('[AdminLog] Failed to send pending approval: $e');
    }
  }
}
