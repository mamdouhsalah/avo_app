import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NotificationSenderService {
  static String get _serviceAccountJson => dotenv.env['FCM_SERVICE_ACCOUNT_JSON'] ?? '';

  static Future<String> _getAccessToken() async {
    final accountCredentials = ServiceAccountCredentials.fromJson(_serviceAccountJson);
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
    try {
      if (_serviceAccountJson.isEmpty || _serviceAccountJson.contains('YOUR_PROJECT_ID')) {
        debugPrint('FCM: Please configure your Service Account JSON in .env!');
        return;
      }

      final Map<String, dynamic> credentials = jsonDecode(_serviceAccountJson);
      final String projectId = credentials['project_id'];

      final String accessToken = await _getAccessToken();

      final String url = 'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

      final Map<String, dynamic> payload = {
        'message': {
          'token': fcmToken,
          'notification': {
            'title': title,
            'body': body,
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
        debugPrint('FCM: Notification sent successfully');
      } else {
        debugPrint('FCM: Failed to send notification: ${response.body}');
      }
    } catch (e) {
      debugPrint('FCM: Error sending notification: $e');
    }
  }
}
