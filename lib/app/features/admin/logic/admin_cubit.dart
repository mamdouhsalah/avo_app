// lib/app/features/admin/logic/admin_cubit.dart
import 'dart:async';
import 'dart:developer';

import 'package:avo_app/app/features/admin/data/admin_repository.dart';
import 'package:avo_app/app/features/admin/logic/admin_state.dart';
import 'package:avo_app/app/features/admin/models/app_log_model.dart';
import 'package:avo_app/app/features/admin/models/pending_approval_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminCubit extends Cubit<AdminState> {
  final AdminRepository repository;

  StreamSubscription<List<AppLogModel>>? _logsSubscription;
  StreamSubscription<List<PendingApprovalModel>>? _approvalsSubscription;
  StreamSubscription<Map<String, int>>? _statsSubscription;

  List<AppLogModel> _allLogs = [];
  List<PendingApprovalModel> _allApprovals = [];
  Map<String, int> stats = {};

  String _logFilter = 'all'; // 'all' | 'info' | 'warning' | 'error' | 'success'
  String _approvalFilter = 'all'; // 'all' | 'pending' | 'approved' | 'rejected'

  AdminCubit({required this.repository}) : super(AdminInitial());

  // ============ Stats ============
  Future<void> loadStats() async {
    emit(AdminLoading());
    try {
      stats = await repository.getStats();
      emit(AdminStatsLoaded(stats));
    } catch (e) {
      log('[AdminCubit] loadStats error: $e');
      emit(AdminError(e.toString()));
    }
  }

  void startListeningStats() {
    _statsSubscription?.cancel();
    _statsSubscription = repository.streamStats().listen(
      (newStats) {
        stats = newStats;
        emit(AdminStatsLoaded(stats));
      },
      onError: (e) {
        log('[AdminCubit] stats stream error: $e');
        emit(AdminError(e.toString()));
      },
    );
  }

  void refreshStats() {
    startListeningStats();
  }

  // ============ Logs ============
  void startListeningLogs() {
    _logsSubscription?.cancel();
    _logsSubscription = repository.streamLogs().listen(
      (logs) {
        _allLogs = logs;
        _applyLogFilter();
      },
      onError: (e) {
        log('[AdminCubit] logs stream error: $e');
        emit(AdminError(e.toString()));
      },
    );
  }

  void refreshLogs() {
    startListeningLogs();
  }

  void filterLogs(String filter) {
    _logFilter = filter;
    _applyLogFilter();
  }

  void _applyLogFilter() {
    if (_logFilter == 'all') {
      emit(AdminLogsLoaded(_allLogs));
    } else {
      final filtered = _allLogs.where((l) => l.level == _logFilter).toList();
      emit(AdminLogsLoaded(filtered));
    }
  }

  // ============ Approvals ============
  void startListeningApprovals() {
    _approvalsSubscription?.cancel();
    _approvalsSubscription = repository.streamPendingApprovals().listen(
      (approvals) {
        _allApprovals = approvals;
        _applyApprovalFilter();
      },
      onError: (e) {
        log('[AdminCubit] approvals stream error: $e');
        emit(AdminError(e.toString()));
      },
    );
  }

  void refreshApprovals() {
    startListeningApprovals();
  }

  void filterApprovals(String filter) {
    _approvalFilter = filter;
    _applyApprovalFilter();
  }

  void _applyApprovalFilter() {
    if (_approvalFilter == 'all') {
      emit(AdminApprovalsLoaded(_allApprovals));
    } else {
      final filtered =
          _allApprovals.where((a) => a.status == _approvalFilter).toList();
      emit(AdminApprovalsLoaded(filtered));
    }
  }

  // ============ Actions ============
  Future<void> approveUser(PendingApprovalModel approval) async {
    emit(AdminLoading());
    try {
      await repository.approveUser(
        approvalId: approval.id,
        userId: approval.userId,
        email: approval.email,
        role: approval.role,
      );
      emit(AdminActionSuccess('User approved successfully ✅'));
      _applyApprovalFilter();
    } catch (e) {
      emit(AdminError(e.toString()));
      _applyApprovalFilter();
    }
  }

  Future<void> rejectUser(PendingApprovalModel approval) async {
    emit(AdminLoading());
    try {
      await repository.rejectUser(
        approvalId: approval.id,
        userId: approval.userId,
        email: approval.email,
      );
      emit(AdminActionSuccess('User rejected ❌'));
      _applyApprovalFilter();
    } catch (e) {
      emit(AdminError(e.toString()));
      _applyApprovalFilter();
    }
  }

  int get pendingCount =>
      _allApprovals.where((a) => a.status == 'pending').length;

  @override
  Future<void> close() {
    _logsSubscription?.cancel();
    _approvalsSubscription?.cancel();
    _statsSubscription?.cancel();
    return super.close();
  }
}