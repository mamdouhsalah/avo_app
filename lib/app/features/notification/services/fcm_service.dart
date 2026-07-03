import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:avo_app/app/core/constants/database_paths.dart';
import 'package:avo_app/app/core/routing/app_router.dart';

import 'package:avo_app/app/features/notification/data/models/notification_model.dart';
import 'package:avo_app/app/features/notification/data/repository/notification_repository_impl.dart';
import 'package:avo_app/app/core/services/local/hive_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  try {
    await HiveService.init();
  } catch (_) {}
  
  await _saveFCMNotification(message);
  debugPrint('📩 Background message: ${message.messageId}');
}

Future<void> _saveFCMNotification(RemoteMessage message) async {
  final notification = message.notification;
  if (notification == null) return;
  
  try {
    final repo = NotificationRepositoryImpl();
    final model = NotificationModel(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: notification.title ?? 'New Message',
      body: notification.body ?? '',
      timestamp: message.sentTime ?? DateTime.now(),
      isRead: false,
      type: 'chat',
      payload: message.data,
    );
    await repo.saveNotification(model);
  } catch (e) {
    debugPrint('⚠️ Could not save FCM notification to Hive: $e');
  }
}

@pragma('vm:entry-point')
void onBackgroundNotificationResponse(NotificationResponse details) {
  debugPrint('🔔 Background notification tapped: ${details.payload}');
}

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'chatapp_messages';
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    _channelId,
    'Chat Messages',
    description: 'Notifications for new chat messages',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  static Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    try {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      debugPrint('⚠️ FCM requestPermission failed: $e');
    }

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
      ),
      onDidReceiveNotificationResponse: (details) {
        _handleNotificationTap();
      },
      onDidReceiveBackgroundNotificationResponse: onBackgroundNotificationResponse,
    );

    // Handle tap from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap();
    });

    // Handle tap from terminated state
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      Future.delayed(const Duration(seconds: 1), () {
        _handleNotificationTap();
      });
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await saveTokenToDatabase();

    // Ensure the token is saved when the user logs in
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        saveTokenToDatabase();
      }
    });

    _messaging.onTokenRefresh.listen((newToken) {
      _updateToken(newToken);
    });
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _saveFCMNotification(message);

    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title ?? 'New Message',
      body: notification.body ?? '',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  static Future<void> saveTokenToDatabase() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      final token = await _messaging.getToken();
      if (token == null) return;

      // تحديث التوكن في الـ RTDB عشان نلاقيه وقت الإرسال
      await FirebaseDatabase.instance.ref('${DatabasePaths.users}/$uid').update({
        'fcmToken': token,
      });
    } catch (e) {
      debugPrint('⚠️ Could not save FCM token: $e');
    }
  }

  static Future<void> _updateToken(String token) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      await FirebaseDatabase.instance.ref('${DatabasePaths.users}/$uid').update({
        'fcmToken': token,
      });
    } catch (_) {}
  }

  static Future<void> _handleNotificationTap() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      final userSnap = await FirebaseDatabase.instance.ref('${DatabasePaths.users}/$uid').get();
      if (userSnap.exists) {
        final data = userSnap.value as Map;
        final role = data['role']?.toString();
        if (role == 'doctor') {
          AppRouter.router.push('/doctor-chats');
        } else {
          AppRouter.router.push('/chats');
        }
      }
    } catch (e) {
      debugPrint('Navigation error: $e');
    }
  }
}
