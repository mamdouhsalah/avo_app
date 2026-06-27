import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:avo_app/app/features/notification/data/models/notification_model.dart';
import 'package:avo_app/app/features/notification/data/repository/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  static const String _boxName = 'app_notifications';

  Future<Box<String>> _getBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<String>(_boxName);
    }
    return await Hive.openBox<String>(_boxName);
  }

  @override
  Stream<List<NotificationModel>> streamNotifications() async* {
    final box = await _getBox();
    
    // Emit initial values
    yield _getNotificationsFromBox(box);

    // Yield updates
    yield* box.watch().map((event) {
      return _getNotificationsFromBox(box);
    });
  }

  List<NotificationModel> _getNotificationsFromBox(Box<String> box) {
    final notifications = box.values.map((jsonStr) {
      final map = jsonDecode(jsonStr) as Map<dynamic, dynamic>;
      return NotificationModel.fromJson(map);
    }).toList();

    notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return notifications;
  }

  @override
  Future<void> saveNotification(NotificationModel notification) async {
    final box = await _getBox();
    await box.put(notification.id, jsonEncode(notification.toJson()));
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final box = await _getBox();
    final jsonStr = box.get(notificationId);
    if (jsonStr != null) {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      map['isRead'] = true;
      await box.put(notificationId, jsonEncode(map));
    }
  }

  @override
  Future<void> markAllAsRead() async {
    final box = await _getBox();
    final updates = <String, String>{};
    for (var key in box.keys) {
      final jsonStr = box.get(key);
      if (jsonStr != null) {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        if (map['isRead'] != true) {
          map['isRead'] = true;
          updates[key.toString()] = jsonEncode(map);
        }
      }
    }
    if (updates.isNotEmpty) {
      await box.putAll(updates);
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    final box = await _getBox();
    await box.delete(notificationId);
  }

  @override
  Future<void> deleteAllNotifications() async {
    final box = await _getBox();
    await box.clear();
  }
}

