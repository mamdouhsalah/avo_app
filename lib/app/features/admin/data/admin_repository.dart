// lib/app/features/admin/data/admin_repository.dart
import 'package:avo_app/app/features/admin/models/app_log_model.dart';
import 'package:avo_app/app/features/admin/models/pending_approval_model.dart';

abstract class AdminRepository {
  Stream<List<AppLogModel>> streamLogs();
  Stream<List<PendingApprovalModel>> streamPendingApprovals();
  Future<Map<String, int>> getStats();
  Stream<Map<String, int>> streamStats();
  Future<void> approveUser({
    required String approvalId,
    required String userId,
    required String email,
    required String role,
  });
  Future<void> rejectUser({
    required String approvalId,
    required String userId,
    required String email,
  });
}
