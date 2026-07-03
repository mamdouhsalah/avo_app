import 'dart:async';
import 'package:avo_app/app/features/notification/data/repository/notification_repository.dart';
import 'package:avo_app/app/features/notification/logic/app_notification_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:avo_app/app/features/notification/data/models/notification_model.dart';
import 'package:awesome_notifications/awesome_notifications.dart'
    hide NotificationModel;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:avo_app/app/core/constants/database_paths.dart';

class AppNotificationCubit extends Cubit<AppNotificationState> {
  final NotificationRepository repository;
  StreamSubscription? _subscription;
  StreamSubscription? _remoteSubscription;

  AppNotificationCubit({required this.repository})
      : super(AppNotificationInitial()) {
    _startListening();
  }

  void _startListening() {
    emit(AppNotificationLoading());
    _subscription?.cancel();
    _remoteSubscription?.cancel();

    // Listen to local Hive database
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

    // Listen to remote Firebase database for new notifications
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _remoteSubscription = FirebaseDatabase.instance
          .ref('${DatabasePaths.notifications}/$uid')
          .onChildAdded
          .listen((event) async {
        if (event.snapshot.value != null) {
          try {
            final data = Map<String, dynamic>.from(event.snapshot.value as Map);
            data['id'] ??= event.snapshot.key ??
                DateTime.now().millisecondsSinceEpoch.toString();

            final newNotification = NotificationModel.fromJson(data);

            // Save to local Hive database
            await repository.saveNotification(newNotification);

            // Remove from Firebase so we don't process it again
            await event.snapshot.ref.remove();

            // Trigger local notification sound/popup
            AwesomeNotifications().createNotification(
              content: NotificationContent(
                id: newNotification.id.hashCode,
                channelKey: 'med_channel',
                title: newNotification.title,
                body: newNotification.body,
                notificationLayout: NotificationLayout.Default,
              ),
            );
          } catch (e) {
            // Ignore parse errors
          }
        }
      }, onError: (error) {
        // Ignore or log permission denied / other Firebase stream errors
        print('Remote notification listener error: $error');
      });
    }
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
    _remoteSubscription?.cancel();
    return super.close();
  }
}
