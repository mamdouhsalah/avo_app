// lib/app/features/admin/views/screen/admin_approvals_screen.dart
import 'package:avo_app/app/features/admin/logic/admin_cubit.dart';
import 'package:avo_app/app/features/admin/logic/admin_state.dart';
import 'package:avo_app/app/features/admin/views/widgets/approval_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AdminApprovalsScreen extends StatefulWidget {
  const AdminApprovalsScreen({super.key});

  @override
  State<AdminApprovalsScreen> createState() => _AdminApprovalsScreenState();
}

class _AdminApprovalsScreenState extends State<AdminApprovalsScreen> {
  final _filters = ['all', 'pending', 'approved', 'rejected'];
  final _labels = ['All', 'Pending', 'Approved', 'Rejected'];
  String _selected = 'pending';

  @override
  void initState() {
    super.initState();
    final cubit = context.read<AdminCubit>();
    cubit.startListeningApprovals();
    cubit.filterApprovals('pending');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Approval Requests'),
        centerTitle: true,
        actions: [
          BlocBuilder<AdminCubit, AdminState>(
            builder: (context, state) {
              final count = context.read<AdminCubit>().pendingCount;
              if (count == 0) return const SizedBox();
              return Container(
                margin: EdgeInsets.only(right: 16.w),
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFD32F2F),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          SizedBox(
            height: 50.h,
            child: ListView.separated(
              padding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemBuilder: (context, i) {
                final isSelected = _selected == _filters[i];
                final color = _filterColor(_filters[i]);
                return GestureDetector(
                  onTap: () {
                    setState(() => _selected = _filters[i]);
                    context
                        .read<AdminCubit>()
                        .filterApprovals(_filters[i]);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color
                          : color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: isSelected
                            ? color
                            : color.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      _labels[i],
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : color,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // List
          Expanded(
            child: BlocConsumer<AdminCubit, AdminState>(
              listener: (context, state) {
                if (state is AdminActionSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: const Color(0xFF00A991),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r)),
                    ),
                  );
                } else if (state is AdminError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error),
                      backgroundColor: const Color(0xFFD32F2F),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is AdminLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF00A991)),
                  );
                }
                if (state is AdminApprovalsLoaded) {
                  if (state.approvals.isEmpty) {
                    return _buildEmpty();
                  }
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.w, vertical: 8.h),
                    itemCount: state.approvals.length,
                    itemBuilder: (context, i) {
                      final approval = state.approvals[i];
                      return ApprovalCard(
                        approval: approval,
                        onApprove: approval.status == 'pending'
                            ? () => _confirmAction(
                                  context: context,
                                  title: 'Approve User',
                                  message:
                                      'Are you sure you want to approve ${approval.fullName}?',
                                  onConfirm: () => context
                                      .read<AdminCubit>()
                                      .approveUser(approval),
                                )
                            : null,
                        onReject: approval.status == 'pending'
                            ? () => _confirmAction(
                                  context: context,
                                  title: 'Reject User',
                                  message:
                                      'Are you sure you want to reject ${approval.fullName}?',
                                  isDestructive: true,
                                  onConfirm: () => context
                                      .read<AdminCubit>()
                                      .rejectUser(approval),
                                )
                            : null,
                      );
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _filterColor(String filter) {
    switch (filter) {
      case 'pending':
        return const Color(0xFFFBC02D);
      case 'approved':
        return const Color(0xFF00A991);
      case 'rejected':
        return const Color(0xFFD32F2F);
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 72.sp,
            color: const Color(0xFF00A991).withValues(alpha: 0.3),
          ),
          SizedBox(height: 16.h),
          Text(
            'No requests found',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAction({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
    bool isDestructive = false,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r)),
        title: Text(title,
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700)),
        content:
            Text(message, style: TextStyle(fontSize: 14.sp)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDestructive ? const Color(0xFFD32F2F) : const Color(0xFF00A991),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r)),
            ),
            child: Text(isDestructive ? 'Reject' : 'Approve'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      onConfirm();
    }
  }
}
