// lib/app/features/admin/models/app_log_model.dart

enum LogLevel { info, warning, error, success }

class AppLogModel {
  final String id;
  final String type;
  final String userId;
  final String email;
  final String message;
  final int timestamp;
  final String level; // 'info' | 'warning' | 'error' | 'success'

  AppLogModel({
    required this.id,
    required this.type,
    required this.userId,
    required this.email,
    required this.message,
    required this.timestamp,
    required this.level,
  });

  LogLevel get logLevel {
    switch (level) {
      case 'warning':
        return LogLevel.warning;
      case 'error':
        return LogLevel.error;
      case 'success':
        return LogLevel.success;
      default:
        return LogLevel.info;
    }
  }

  factory AppLogModel.fromJson(Map<String, dynamic> json) {
    return AppLogModel(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      timestamp: (json['timestamp'] as num?)?.toInt() ?? 0,
      level: json['level']?.toString() ?? 'info',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'userId': userId,
      'email': email,
      'message': message,
      'timestamp': timestamp,
      'level': level,
    };
  }

  DateTime get dateTime =>
      DateTime.fromMillisecondsSinceEpoch(timestamp);
}
