import 'package:avo_app/app/core/routing/app_router.dart';
import 'package:avo_app/app/core/services/remote/firebase_consumer_impl.dart';
import 'package:avo_app/app/features/auth/logic/auth_cubit.dart';
import 'package:avo_app/app/features/notification/logic/app_notification_cubit.dart';
import 'package:avo_app/app/features/notification/logic/app_notification_state.dart';
import 'package:avo_app/app/features/pharmacy/data/pharmacy_repository_impl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:avo_app/app/features/pharmacy/view/widget/pharmacy_custom_drawer.dart';
import 'package:avo_app/app/features/profile/logic/profile_cubit.dart';

class PharmacyDashboardScreen extends StatefulWidget {
  const PharmacyDashboardScreen({super.key});

  @override
  State<PharmacyDashboardScreen> createState() =>
      _PharmacyDashboardScreenState();
}

class _PharmacyDashboardScreenState extends State<PharmacyDashboardScreen> {
  final _repo = PharmacyRepositoryImpl(consumer: FirebaseConsumerImpl());
  bool _isLoading = true;
  int _ordersCount = 0;
  int _pendingCount = 0;
  String _pharmacyName = 'Pharmacy';

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isNotEmpty) {
      final pharmacy = await _repo.getPharmacyProfile(uid);
      final orders = await _repo.getPharmacyOrders(uid);
      final pendingCount = orders.where((o) => o.status == 'pending').length;
      
      if (mounted) {
        setState(() {
          _pharmacyName = pharmacy?.name ?? 'Pharmacy';
          _ordersCount = orders.length;
          _pendingCount = pendingCount;
          _isLoading = false;
        });
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        drawer: const PharmacyCustomDrawer(),
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Pharmacy',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey,
                ),
              ),
              Text(
                context.watch<ProfileCubit>().userProfile?.fullName ??
                    _pharmacyName,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          centerTitle: false,
          elevation: 0,
          backgroundColor: theme.scaffoldBackgroundColor,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadDashboardData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(16.sp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Overview',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          BlocBuilder<AppNotificationCubit,
                              AppNotificationState>(
                            builder: (context, state) {
                              int unreadCount = 0;
                              if (state is AppNotificationLoaded) {
                                unreadCount = state.unreadCount;
                              }
                              return Stack(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                        Icons.notifications_active_outlined,
                                        color: theme.colorScheme.primary),
                                    onPressed: () {
                                      context.push(AppRouter.notifications);
                                    },
                                  ),
                                  if (unreadCount > 0)
                                    Positioned(
                                      right: 8,
                                      top: 8,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          unreadCount > 99
                                              ? '99+'
                                              : unreadCount.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              context,
                              title: 'Total Orders',
                              value: '$_ordersCount',
                              icon: Icons.shopping_bag_outlined,
                              color: Colors.blue,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: _buildStatCard(
                              context,
                              title: 'Pending',
                              value: '$_pendingCount', // Now uses actual pending count
                              icon: Icons.pending_actions,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32.h),
                      Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      _buildActionTile(
                        context,
                        title: 'Manage Orders',
                        subtitle: 'View and process incoming patient orders',
                        icon: Icons.list_alt,
                        onTap: () {
                          context.push(AppRouter.pharmacyOrders).then((_) {
                            _loadDashboardData();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: 130.h),
          child: GestureDetector(
            onTap: () {
              context.push(AppRouter.chatBot);
            },
            child: Container(
              width: 86.w,
              height: 86.h,
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.primary,
                  width: 2.w,
                ),
                shape: BoxShape.circle,
              ),
              child: Container(
                width: 86.w,
                height: 86.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.surface.withValues(alpha: 0.85),
                ),
                child: Image.asset(
                  'assets/imgs/chatbut/chatbut.png',
                  color: theme.colorScheme.primary,
                  colorBlendMode: BlendMode.srcIn,
                  height: 70.h,
                  width: 70.w,
                ),
              ),
            ),
          ),
        ));
  }

  Widget _buildStatCard(BuildContext context,
      {required String title,
      required String value,
      required IconData icon,
      required Color color}) {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28.sp),
          SizedBox(height: 12.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(BuildContext context,
      {required String title,
      required String subtitle,
      required IconData icon,
      required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.all(16.sp),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        title: Text(title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
