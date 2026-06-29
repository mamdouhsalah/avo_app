class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final String? type;
  final Map<String, dynamic>? payload;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.type,
    this.payload,
  });

  factory NotificationModel.fromJson(Map<dynamic, dynamic> json) {
    DateTime parsedTimestamp = DateTime.now();
    if (json['timestamp'] != null) {
      if (json['timestamp'] is int) {
        parsedTimestamp = DateTime.fromMillisecondsSinceEpoch(json['timestamp']);
      } else if (json['timestamp'] is String) {
        parsedTimestamp = DateTime.tryParse(json['timestamp']) ?? DateTime.now();
      }
    }

    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'New Notification',
      body: json['body']?.toString() ?? '',
      timestamp: parsedTimestamp,
      isRead: json['isRead'] == true || json['isRead'] == 'true',
      type: json['type']?.toString(),
      payload: json['payload'] is Map ? Map<String, dynamic>.from(json['payload']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isRead': isRead,
      if (type != null) 'type': type,
      if (payload != null) 'payload': payload,
    };
  }
}

