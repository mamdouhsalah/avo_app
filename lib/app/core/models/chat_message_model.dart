class ChatMessageModel {
  final String text;
  final bool isUser;
  final String time;

  ChatMessageModel({
    required this.text,
    required this.isUser,
    required this.time,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ChatMessageModel(
        text: '',
        isUser: false,
        time: '',
      );
    }
    return ChatMessageModel(
      text: json['text']?.toString() ?? '',
      isUser: json['isUser'] as bool? ?? false,
      time: json['time']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'time': time,
    };
  }
}