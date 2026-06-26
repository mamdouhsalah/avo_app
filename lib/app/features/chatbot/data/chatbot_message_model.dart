class ChatbotMessageModel {
  final String id;
  final String text;
  final bool isUser;
  final String time;

  ChatbotMessageModel({
    required this.id,
    required this.text,
    required this.isUser,
    required this.time,
  });

  ChatbotMessageModel copyWith({
    String? id,
    String? text,
    bool? isUser,
    String? time,
  }) {
    return ChatbotMessageModel(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      time: time ?? this.time,
    );
  }
}