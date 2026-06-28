import 'package:avo_app/app/features/notification/data/models/notification_model.dart';

abstract class NotificationRepository {
  Stream<List<NotificationModel>> streamNotifications();
  Future<void> saveNotification(NotificationModel notification);
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String notificationId);
  Future<void> deleteAllNotifications();
}
