import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:avo_app/app/features/chatbot/data/chatbot_message_model.dart';

import 'package:avo_app/app/core/services/local/gemini_service.dart';
import 'chatbot_state.dart';

class ChatbotCubit extends Cubit<ChatbotState> {
  late final GeminiService _geminiService;
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  Timer? _typingTimer;

  ChatbotCubit() : super(const ChatbotState()) {
    _geminiService = GeminiService();
    _initVoice();
    _addWelcomeMessage();
  }

  Future<void> _initVoice() async {
    await _speech.initialize();
    await _flutterTts.setLanguage("ar-EG");
    await _flutterTts.setSpeechRate(0.5);

    _flutterTts.setCompletionHandler(() {
      emit(state.copyWith(isSpeaking: false, currentlySpeakingMessageId: null));
    });
    _flutterTts.setCancelHandler(() {
      emit(state.copyWith(isSpeaking: false, currentlySpeakingMessageId: null));
    });
  }

  void _addWelcomeMessage() {
    final welcomeMessage = ChatbotMessageModel(
      id: const Uuid().v4(),
      text: 'أهلاً بيك! أنا المساعد الطبي الخاص بيك، أقدر أساعدك إزاي النهاردة؟',
      isUser: false,
      time: DateFormat('hh:mm a').format(DateTime.now()),
    );
    emit(state.copyWith(messages: [welcomeMessage]));
  }

  Future<void> sendMessage(String text, {Map<String, Function>? functions}) async {
    if (text.trim().isEmpty || state.isGenerating) return;

    await stopSpeaking();
    if (state.isListening) {
      await _speech.stop();
      emit(state.copyWith(isListening: false));
    }

    final textMessage = ChatbotMessageModel(
      id: const Uuid().v4(),
      text: text,
      isUser: true,
      time: DateFormat('hh:mm a').format(DateTime.now()),
    );

    emit(state.copyWith(
      messages: [textMessage, ...state.messages],
      isGenerating: true,
    ));

    try {
      final response = await _geminiService.sendMessage(text, functions: functions);
      
      if (response.isNotEmpty) {
        final messageId = const Uuid().v4();
        final aiMessage = ChatbotMessageModel(
          id: messageId,
          text: '', // Start empty for typing animation
          isUser: false,
          time: DateFormat('hh:mm a').format(DateTime.now()),
        );
        
        emit(state.copyWith(
          messages: [aiMessage, ...state.messages],
        ));

        _startTypingAnimation(response, messageId);
      } else {
        emit(state.copyWith(isGenerating: false));
      }
    } catch (e) {
      emit(state.copyWith(isGenerating: false, error: e.toString()));
    }
  }

  void _startTypingAnimation(String response, String messageId) {
    emit(state.copyWith(
      isTyping: true,
      typingMessageId: messageId,
      displayedText: '',
      isGenerating: false, // Finished generating, now typing
    ));

    int charCount = 0;
    _typingTimer?.cancel();
    _typingTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      charCount++;
      if (charCount <= response.length) {
        emit(state.copyWith(displayedText: response.substring(0, charCount)));
      } else {
        timer.cancel();
        // Update the actual message
        final messages = List<ChatbotMessageModel>.from(state.messages);
        final index = messages.indexWhere((msg) => msg.id == messageId);
        if (index != -1) {
          messages[index] = messages[index].copyWith(text: response);
        }
        
        emit(state.copyWith(
          messages: messages,
          isTyping: false,
          typingMessageId: null,
          displayedText: '',
        ));
      }
    });
  }

  Future<void> toggleSpeak(String text, String messageId) async {
    if (state.isSpeaking && state.currentlySpeakingMessageId == messageId) {
      await _flutterTts.stop();
      emit(state.copyWith(isSpeaking: false, currentlySpeakingMessageId: null));
    } else {
      await _flutterTts.stop();
      emit(state.copyWith(isSpeaking: true, currentlySpeakingMessageId: messageId));
      await _flutterTts.speak(text);
    }
  }

  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
    emit(state.copyWith(isSpeaking: false, currentlySpeakingMessageId: null));
  }

  void stopGeneration() {
    _typingTimer?.cancel();
    emit(state.copyWith(
      isGenerating: false,
      isTyping: false,
    ));
    // We would ideally cancel the Gemini request but we can just ignore it or let it finish
  }

  Future<void> listen(void Function(String) onRecognized) async {
    if (state.isGenerating) return;

    if (!state.isListening) {
      await stopSpeaking();
      bool available = await _speech.initialize();
      if (available) {
        emit(state.copyWith(isListening: true));
        _speech.listen(
          onResult: (val) {
            onRecognized(val.recognizedWords);
          },
          listenOptions: stt.SpeechListenOptions(localeId: "ar-EG"),
        );
      }
    } else {
      emit(state.copyWith(isListening: false));
      await _speech.stop();
    }
  }

  @override
  Future<void> close() {
    _typingTimer?.cancel();
    _speech.stop();
    _flutterTts.stop();
    return super.close();
  }
}
