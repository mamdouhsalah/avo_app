class ChatMessageModel {
  final String text;
  final bool isUser;
  final String time;

  ChatMessageModel({
    required this.text,
    required this.isUser,
    required this.time,
  });
}