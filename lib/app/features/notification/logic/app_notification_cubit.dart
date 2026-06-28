import 'dart:async';
import 'package:avo_app/app/features/notification/data/repository/notification_repository.dart';
import 'package:avo_app/app/features/notification/logic/app_notification_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppNotificationCubit extends Cubit<AppNotificationState> {
  final NotificationRepository repository;
  StreamSubscription? _subscription;

  AppNotificationCubit({required this.repository}) : super(AppNotificationInitial()) {
    _startListening();
  }

  void _startListening() {
    emit(AppNotificationLoading());
    _subscription?.cancel();
    
    _subscription = repository.streamNotifications().listen(
      (notifications) {
        final unreadCount = notifications.where((n) => !n.isRead).length;
        emit(AppNotificationLoaded(
          notifications: notifications,
          unreadCount: unreadCount,
          totalCount: notifications.length,
        ));
      },
      onError: (error) {
        emit(AppNotificationError(error.toString()));
      },
    );
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await repository.markAsRead(notificationId);
    } catch (e) {
      // Ignore
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await repository.markAllAsRead();
    } catch (e) {
      // Ignore
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await repository.deleteNotification(notificationId);
    } catch (e) {
      // Ignore
    }
  }

  Future<void> deleteAllNotifications() async {
    try {
      await repository.deleteAllNotifications();
    } catch (e) {
      // Ignore
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}


