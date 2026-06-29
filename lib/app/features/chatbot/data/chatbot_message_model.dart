import 'dart:typed_data';

class ChatbotMessageModel {
  final String id;
  final String text;
  final bool isUser;
  final String time;
  final bool isLoading;
  final bool isError;
  final Uint8List? imageBytes;

  const ChatbotMessageModel({
    required this.id,
    required this.text,
    required this.isUser,
    required this.time,
    this.isLoading = false,
    this.isError = false,
    this.imageBytes,
  });

  ChatbotMessageModel copyWith({
    String? id,
    String? text,
    bool? isUser,
    String? time,
    bool? isLoading,
    bool? isError,
    Uint8List? imageBytes,
  }) {
    return ChatbotMessageModel(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      time: time ?? this.time,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      imageBytes: imageBytes ?? this.imageBytes,
    );
  }
}