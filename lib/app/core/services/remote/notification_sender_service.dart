import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';

class NotificationSenderService {
  // TODO: استبدل المحتوى ده بمحتوى ملف الـ JSON اللي هتحمله من Firebase Service Accounts
  static const String _serviceAccountJson = r'''
{
  "type": "service_account",
  "project_id": "avo-project-f2f8f",
  "private_key_id": "5bf4b67b5474c4b4331fcb0587c66a7af9363491",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCnyX6q5VE/wPqK\nS6t4GXKqt83QjeN3dgs4OI1ywEMitsOAsp6bEqKDWDhkWTgxq3sD8xeNz/LIZvLF\nKYofT+aK6mfpKUkJcQ5qe8MPw22p0MEV39lMhrcgJTG8TTS1qyEAbOGEWORUU0AF\n+MQdgIhL8J6HXKAETMNMwH09DExM2qO9OUUxRoDu8uW2969fGkO4PB/dH9wkYAql\nopWQT895jebw/OuAIbWQ+qDKPpAnl44HFhsyKzpRuavFGLHUC+ptADGRtmD7efU+\nbxKBptvjvNJnF6mTt//PJLseXFjlQ8rXUH1hpRVwthfi1xmCV4c7nM2KWVAD83hD\nCYF+0kexAgMBAAECggEAFRuDjFMp2/fWbNRlH0gwRSq3QQ/AeFRIyAtRPAjUyUat\npICT9FUtTZGpEnKo35K/eHk50tTAqZZN3yDBJ/xAt+QSK2JOtlnbIukr2k1O++hv\nieVtrDNcUTZsodAim+IJ1khcPG6EVtlcOgQYA9AaFVeRUd0EolXX0c17U9U6ugYp\nEuEXHrLTCwL77LQbRTMK+0lMM9VlbpbO8iZQRNa3flfdI4AlrJcTpKqP9GFXoE61\nB8wpMU4F0YE+I709G6iSzt7yYFPIO+MOCnBdTwNlGMKEBRE6SGZata88hU0hGAoz\nyb8Vx6N0fP7WzYXqDl0fX7OwctC8dcoMcRM0+TMoSwKBgQDZqkjXic6dywRPC5+g\n32zTK5uXuVi9KazWv9KH9djv981wu/f3mwkDBRDKNlhQN0CCrAu5J4w5TeG0YOSP\nt4UgaYLrcJl4PLZ+qeZ+yB0B+n8eXA/6E80+pbruSNcyuFOJmRLOBK4uVthxsfoB\nVbBUn0sVC3Fa+WBDwweLD2dq4wKBgQDFVmRzT+AKVPH1pgSLt8re0RX7iWeZkbGO\nUczPkwM2mmEypPMH5mCWu5n0qv388Q8yhr0o0MgsfE3Y1nmhUKfQGfJkAebY81Lr\nzEXjKDKsDzp7F8zBYY92EE9qepUkxeL0cKf8wDYyPvolDdTVGHrdcXOLzDOqoHU7\n0wCcRBjjWwKBgFxXRH3EJdaFWTebi8X44zcXCfQtGnttobidOliZsMXlD8/ivojZ\nydHxJTVUJtUpC4IkMPkE0RVCeB1I+c4Kojyk5nixlToQL6++rl1c0gmT1rfvgIus\nOOd58brDRiBrWG1IdlTWYXqhN0PMqG5Ghv7vcS/lYdqhbvhwVdPl3g7XAoGAT3fz\nC9zmxEJhDiPFQN7K++AHkjxLVDSv5Dhc2lrBuIODEPoMROopi4oQ/c6+adZJ4HcS\nRhWOBxwn3WLBqIzqh4traYq6hDO4+OxSWKAfh9q6GkgDVP0M4ObAlIi49w4Zz4Zu\noAJn0OQ7qCBhzU8Ga5b8iRe61sO3clgOrt9dhnECgYAE9CXQRg8Q/daNisyCtLFm\nEfko3JglgksV28MOSvyXZjfsHaJUbbYGDi77Yo2H53jSafRjNd1Hz/LPDxkWTX1W\nn2xWg/6Jx5+2cPnReDREehhXo9TH+Kxmfc1PG32UfoqTK9GchkcOLp13CzhkSME7\nAIEExIcyoQEuqHv5/95jgA==\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-fbsvc@avo-project-f2f8f.iam.gserviceaccount.com",
  "client_id": "106750015135536058094",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40avo-project-f2f8f.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
  ''';

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
      if (_serviceAccountJson.contains('YOUR_PROJECT_ID')) {
        print('FCM: Please configure your Service Account JSON!');
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
        print('FCM: Notification sent successfully');
      } else {
        print('FCM: Failed to send notification: ${response.body}');
      }
    } catch (e) {
      print('FCM: Error sending notification: $e');
    }
  }
}
