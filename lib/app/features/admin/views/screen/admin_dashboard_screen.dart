// lib/app/features/admin/views/screen/admin_dashboard_screen.dart
import 'package:avo_app/app/core/constants/app_colors.dart';
import 'package:avo_app/app/core/constants/database_paths.dart';
import 'package:avo_app/app/core/routing/app_router.dart';
import 'package:avo_app/app/features/admin/logic/admin_cubit.dart';
import 'package:avo_app/app/features/admin/logic/admin_state.dart';
import 'package:avo_app/app/features/admin/views/widgets/admin_custom_drawer.dart';
import 'package:avo_app/app/features/admin/views/widgets/log_tile.dart';
import 'package:avo_app/app/features/admin/views/widgets/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<AdminCubit>();
    // لو الـ Cubit عنده ميثود startListeningStats استخدمها بدل loadStats
    // عشان الإحصائيات تتحدث لحظيًا مع أي تغيير في الداتا بيز.
    cubit.startListeningStats();
    cubit.startListeningLogs();
    cubit.startListeningApprovals();
  }

  Future<void> _refreshAll() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    final cubit = context.read<AdminCubit>();
    try {
      cubit.startListeningStats();
      cubit.startListeningLogs();
      cubit.startListeningApprovals();
      // فترة قصيرة عشان الـ RefreshIndicator يبان وهو شغال
      await Future.delayed(const Duration(milliseconds: 500));
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: AdminCustomDrawer(),
      body: RefreshIndicator(
        color: AppColors.lightPrimary,
        onRefresh: _refreshAll,
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 140.h,
              pinned: true,
              backgroundColor: isDark
                  ? const Color(0xFF121212)
                  : AppColors.lightBackground,
              actions: [
                IconButton(
                  icon: _isRefreshing
                      ? SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.lightPrimary,
                          ),
                        )
                      : Icon(
                          Icons.refresh_rounded,
                          color: AppColors.lightPrimary,
                          size: 22.sp,
                        ),
                  onPressed: _isRefreshing ? null : _refreshAll,
                  tooltip: 'تحديث',
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [
                              const Color(0xFF1A2A28),
                              const Color(0xFF121212),
                            ]
                          : [
                              AppColors.lightPrimary.withValues(alpha: 0.08),
                              AppColors.lightBackground,
                            ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 12.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.r),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF00A991),
                                      Color(0xFF00C4AA),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  Icons.admin_panel_settings_rounded,
                                  color: Colors.white,
                                  size: 22.sp,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Admin Dashboard',
                                    style: TextStyle(
                                      fontSize: 22.sp,
                                      fontWeight: FontWeight.w800,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                  Text(
                                    'AVO Admin Panel',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColors.lightPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              // Logout
                              IconButton(
                                icon: Icon(
                                  Icons.logout_rounded,
                                  color: AppColors.error,
                                  size: 22.sp,
                                ),
                                onPressed: () => _showLogoutDialog(context),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: EdgeInsets.all(16.r),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ===================== Stats =====================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Overview Stats',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      if (_isRefreshing)
                        SizedBox(
                          width: 16.w,
                          height: 16.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.lightPrimary,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  BlocBuilder<AdminCubit, AdminState>(
                    buildWhen: (prev, curr) => curr is AdminStatsLoaded,
                    builder: (context, state) {
                      final stats = context.read<AdminCubit>().stats;
                      return GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                        childAspectRatio: 1.25,
                        children: [
                          StatCard(
                            title: 'Users',
                            value: '${stats[DatabasePaths.users] ?? 0}',
                            icon: Icons.people_rounded,
                            color: AppColors.lightPrimary,
                            onTap: () => context.push(AppRouter.adminUsers),
                          ),
                          StatCard(
                            title: 'Doctors',
                            value: '${stats[DatabasePaths.doctors] ?? 0}',
                            icon: Icons.medical_services_rounded,
                            color: const Color(0xFF0095FF),
                            onTap: () {
                              // TODO: Add Admin Doctors Screen
                            },
                          ),
                          StatCard(
                            title: 'Appointments',
                            value:
                                '${stats[DatabasePaths.appointments] ?? 0}',
                            icon: Icons.calendar_month_rounded,
                            color: const Color(0xFF735BF2),
                            onTap: () {
                              // TODO: Add Admin Appointments Screen
                            },
                          ),
                          StatCard(
                            title: 'Pending Approvals',
                            value:
                                '${stats[DatabasePaths.pendingApprovals] ?? 0}',
                            icon: Icons.pending_actions_rounded,
                            color: const Color(0xFFFBC02D),
                            onTap: () =>
                                context.push(AppRouter.adminApprovals),
                          ),
                        ],
                      );
                    },
                  ),

                  SizedBox(height: 24.h),

                  // ===================== Quick Actions =====================
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.list_alt_rounded,
                          label: 'System Logs',
                          color: AppColors.lightPrimary,
                          onTap: () => context.push(AppRouter.adminLogs),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.how_to_reg_rounded,
                          label: 'Approvals',
                          color: const Color(0xFFFBC02D),
                          onTap: () => context.push(AppRouter.adminApprovals),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.people_alt_rounded,
                          label: 'Users',
                          color: const Color(0xFF0095FF),
                          onTap: () => context.push(AppRouter.adminUsers),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  // ===================== Recent Logs =====================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Events',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push(AppRouter.adminLogs),
                        child: Text(
                          'View All',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.lightPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  BlocBuilder<AdminCubit, AdminState>(
                    buildWhen: (prev, curr) => curr is AdminLogsLoaded,
                    builder: (context, state) {
                      if (state is AdminLogsLoaded) {
                        final recent = state.logs.take(5).toList();
                        if (recent.isEmpty) {
                          return _buildEmptyLogs();
                        }
                        return Column(
                          children:
                              recent.map((log) => LogTile(log: log)).toList(),
                        );
                      }
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(
                            color: AppColors.lightPrimary,
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 32.h),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyLogs() {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: AppColors.lightPrimary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.lightPrimary.withValues(alpha: 0.15),
        ),
      ),
      child: Center(
        child: Text(
          'No events logged yet',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.lightPrimary.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('Logout',
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700)),
        content: Text(
            'Are you sure you want to logout from the Admin Dashboard?',
            style: TextStyle(fontSize: 14.sp)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.go(AppRouter.login);
    }
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26.sp),
            SizedBox(height: 6.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}