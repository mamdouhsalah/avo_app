import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:avo_app/app/features/notification/logic/app_notification_cubit.dart';
import 'package:avo_app/app/features/notification/logic/app_notification_state.dart';
import 'package:avo_app/app/features/notification/view/widgets/notification_card.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    // Mark all as read when opening the screen
    context.read<AppNotificationCubit>().markAllAsRead();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text('Notifications',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            )),
        actions: [
          BlocBuilder<AppNotificationCubit, AppNotificationState>(
            builder: (context, state) {
              if (state is AppNotificationLoaded && state.notifications.isNotEmpty) {
                return IconButton(
                  icon: Icon(Icons.delete_sweep_rounded, color: theme.colorScheme.error),
                  onPressed: () {
                    _showDeleteAllDialog(context);
                  },
                );
              }
              return const SizedBox.shrink();
            },
          )
        ],
      ),
      body: BlocBuilder<AppNotificationCubit, AppNotificationState>(
        builder: (context, state) {
          if (state is AppNotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AppNotificationError) {
            return Center(
              child: Text(
                'Failed to load notifications',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            );
          } else if (state is AppNotificationLoaded) {
            final notifications = state.notifications;
            final totalCount = state.totalCount;
            
            if (notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(24.r),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications_off_outlined,
                        size: 64.sp,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No notifications yet',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'When you get notifications, they\'ll show up here',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Text(
                    'You have $totalCount notification${totalCount == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return Dismissible(
                        key: Key(notification.id),
                        direction: DismissDirection.horizontal,
                        background: _buildDismissBackground(theme, Alignment.centerLeft),
                        secondaryBackground: _buildDismissBackground(theme, Alignment.centerRight),
                        onDismissed: (direction) {
                          context.read<AppNotificationCubit>().deleteNotification(notification.id);
                        },
                        child: NotificationCard(
                          notification: notification,
                          onTap: () {
                            if (!notification.isRead) {
                              context.read<AppNotificationCubit>().markAsRead(notification.id);
                            }
                            // Handle navigation if there is payload
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDismissBackground(ThemeData theme, Alignment alignment) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12.r),
      ),
      alignment: alignment,
      child: Icon(
        Icons.delete_outline,
        color: theme.colorScheme.onError,
        size: 28.sp,
      ),
    );
  }

  Future<void> _showDeleteAllDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('Clear All Notifications',
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to delete all notifications?',
            style: TextStyle(fontSize: 14.sp)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
              elevation: 0,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<AppNotificationCubit>().deleteAllNotifications();
    }
  }
}


