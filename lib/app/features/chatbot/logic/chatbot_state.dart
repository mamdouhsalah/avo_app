import 'package:avo_app/app/features/chatbot/data/chatbot_message_model.dart';

class ChatbotState {
  final List<ChatbotMessageModel> messages;
  final bool isListening;
  final bool isGenerating;
  final bool isSpeaking;
  final String? currentlySpeakingMessageId;
  final String? error;
  
  // For typing animation
  final bool isTyping;
  final String? typingMessageId;
  final String displayedText;

  const ChatbotState({
    this.messages = const [],
    this.isListening = false,
    this.isGenerating = false,
    this.isSpeaking = false,
    this.currentlySpeakingMessageId,
    this.error,
    this.isTyping = false,
    this.typingMessageId,
    this.displayedText = '',
  });

  ChatbotState copyWith({
    List<ChatbotMessageModel>? messages,
    bool? isListening,
    bool? isGenerating,
    bool? isSpeaking,
    String? currentlySpeakingMessageId,
    String? error,
    bool? isTyping,
    String? typingMessageId,
    String? displayedText,
  }) {
    return ChatbotState(
      messages: messages ?? this.messages,
      isListening: isListening ?? this.isListening,
      isGenerating: isGenerating ?? this.isGenerating,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      currentlySpeakingMessageId: currentlySpeakingMessageId ?? this.currentlySpeakingMessageId,
      error: error,
      isTyping: isTyping ?? this.isTyping,
      typingMessageId: typingMessageId ?? this.typingMessageId,
      displayedText: displayedText ?? this.displayedText,
    );
  }
}
