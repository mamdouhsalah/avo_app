import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';

class NotificationSenderService {
  static String? _cachedServiceAccountJson;

  static Future<String> _loadServiceAccountJson() async {
    if (_cachedServiceAccountJson != null) return _cachedServiceAccountJson!;
    try {
      _cachedServiceAccountJson =
          await rootBundle.loadString('assets/service_account.json');
    } catch (e) {
      log('FCM: Could not load service_account.json: $e');
      _cachedServiceAccountJson = '';
    }
    return _cachedServiceAccountJson!;
  }

  static Future<String> _getAccessToken() async {
    final json = await _loadServiceAccountJson();
    final accountCredentials = ServiceAccountCredentials.fromJson(json);
    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
    final client = await clientViaServiceAccount(accountCredentials, scopes);
    final token = client.credentials.accessToken.data;
    client.close();
    return token;
  }

  static Future<void> sendNotification({
    required String fcmToken,
    required String title,
    required String body,
    required String chatId,
    required String senderId,
  }) async {
    log('FCM: Starting sendNotification to $fcmToken');
    try {
      final serviceAccountJson = await _loadServiceAccountJson();
      if (serviceAccountJson.isEmpty) {
        log('FCM: service_account.json is missing or empty!');
        return;
      }

      final Map<String, dynamic> credentials = jsonDecode(serviceAccountJson);
      final String projectId = credentials['project_id'];

      final String accessToken = await _getAccessToken();
      log('FCM: Access token obtained successfully');

      final String url = 'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

      final Map<String, dynamic> payload = {
        'message': {
          'token': fcmToken,
          'notification': {
            'title': title,
            'body': body,
          },
          'android': {
            'priority': 'HIGH',
            'notification': {
              'channel_id': 'chatapp_messages',
              'sound': 'default',
            }
          },
          'data': {
            'chatId': chatId,
            'senderId': senderId,
          },
        }
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        log('FCM: Notification sent successfully');
      } else {
        log('FCM: Failed to send notification: ${response.body}');
      }
    } catch (e) {
      log('FCM: Error sending notification: $e');
    }
  }
}
