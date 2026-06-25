class ChatMessageModel {
  final String id;
  final String text;
  final bool isUser;
  final String time;

  ChatMessageModel({
    required this.id,
    required this.text,
    required this.isUser,
    required this.time,
  });

  ChatMessageModel copyWith({
    String? id,
    String? text,
    bool? isUser,
    String? time,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      time: time ?? this.time,
    );
  }
}