// lib/app/features/admin/logic/admin_state.dart
import 'package:avo_app/app/features/admin/models/app_log_model.dart';
import 'package:avo_app/app/features/admin/models/pending_approval_model.dart';

abstract class AdminState {}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminStatsLoaded extends AdminState {
  final Map<String, int> stats;
  AdminStatsLoaded(this.stats);
}

class AdminLogsLoaded extends AdminState {
  final List<AppLogModel> logs;
  AdminLogsLoaded(this.logs);
}

class AdminApprovalsLoaded extends AdminState {
  final List<PendingApprovalModel> approvals;
  AdminApprovalsLoaded(this.approvals);
}

class AdminActionSuccess extends AdminState {
  final String message;
  AdminActionSuccess(this.message);
}

class AdminError extends AdminState {
  final String error;
  AdminError(this.error);
}
