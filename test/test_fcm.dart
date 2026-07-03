import 'dart:convert';
import 'dart:io';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

void main() async {
  try {
    final jsonContent = await File('assets/service_account.json').readAsString();
    final credentials = jsonDecode(jsonContent);
    final projectId = credentials['project_id'];
    print('Project ID: $projectId');

    final accountCredentials = ServiceAccountCredentials.fromJson(jsonContent);
    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
    
    print('Getting access token...');
    final client = await clientViaServiceAccount(accountCredentials, scopes);
    final token = client.credentials.accessToken.data;
    client.close();
    
    print('Access Token obtained: ${token.substring(0, 10)}...');
    print('FCM Credentials work correctly!');
  } catch (e) {
    print('Error: $e');
  }
}
