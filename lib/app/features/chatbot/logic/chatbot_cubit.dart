import 'dart:async';
import 'dart:typed_data';
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

  // ── Voice Initialization ─────────────────────
  Future<void> _initVoice() async {
    await _speech.initialize();

    // Default language — Arabic
    await _setTtsLanguage('ar');

    _flutterTts.setCompletionHandler(() {
      emit(state.copyWith(isSpeaking: false, currentlySpeakingMessageId: null));
    });
    _flutterTts.setCancelHandler(() {
      emit(state.copyWith(isSpeaking: false, currentlySpeakingMessageId: null));
    });
    _flutterTts.setErrorHandler((_) {
      emit(state.copyWith(isSpeaking: false, currentlySpeakingMessageId: null));
    });
  }

  /// Detects if the text is predominantly Arabic and sets TTS language accordingly.
  Future<void> _setTtsLanguage(String langCode) async {
    if (langCode == 'ar') {
      await _flutterTts.setLanguage('ar-EG');
      await _flutterTts.setSpeechRate(0.45);
      await _flutterTts.setPitch(1.0);
    } else {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setPitch(1.0);
    }
  }

  String _detectLanguage(String text) {
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    final arabicCount = arabicRegex.allMatches(text).length;
    // If more than 20% Arabic characters → Arabic
    return arabicCount > text.length * 0.2 ? 'ar' : 'en';
  }

  // ── Welcome Message ──────────────────────────
  void _addWelcomeMessage() {
    final welcomeMessage = ChatbotMessageModel(
      id: const Uuid().v4(),
      text: 'أهلاً بيك! أنا AVOBot، مساعدك الطبي الذكي.\n'
          'Hello! I\'m AVOBot, your smart medical assistant.\n'
          'اسألني بالعربي أو English وأنا هرد بنفس لغتك 😊',
      isUser: false,
      time: DateFormat('hh:mm a').format(DateTime.now()),
    );
    emit(state.copyWith(messages: [welcomeMessage]));
  }

  // ── Send Message ─────────────────────────────
  Future<void> sendMessage(String text,
      {Map<String, Function>? functions, Uint8List? imageBytes}) async {
    if ((text.trim().isEmpty && imageBytes == null) || state.isGenerating) {
      return;
    }

    await stopSpeaking();
    if (state.isListening) {
      await _speech.stop();
      emit(state.copyWith(isListening: false));
    }

    final userMessage = ChatbotMessageModel(
      id: const Uuid().v4(),
      text: text,
      isUser: true,
      time: DateFormat('hh:mm a').format(DateTime.now()),
      imageBytes: imageBytes,
    );

    // Show user message + loading bubble
    final loadingId = const Uuid().v4();
    final loadingMessage = ChatbotMessageModel(
      id: loadingId,
      text: '',
      isUser: false,
      isLoading: true,
      time: DateFormat('hh:mm a').format(DateTime.now()),
    );

    emit(state.copyWith(
      messages: [loadingMessage, userMessage, ...state.messages],
      isGenerating: true,
    ));

    final result = await _geminiService.sendMessage(text,
        functions: functions, imageBytes: imageBytes);

    switch (result) {
      case GeminiSuccess(:final text):
        if (text.isNotEmpty) {
          _replaceLoadingWithTyping(loadingId, text);
        } else {
          _removeLoading(loadingId);
        }

      case GeminiError(:final message):
        final errorMsg = ChatbotMessageModel(
          id: loadingId,
          text: message,
          isUser: false,
          isError: true,
          time: DateFormat('hh:mm a').format(DateTime.now()),
        );
        final msgs = List<ChatbotMessageModel>.from(state.messages);
        final idx = msgs.indexWhere((m) => m.id == loadingId);
        if (idx != -1) msgs[idx] = errorMsg;
        emit(state.copyWith(messages: msgs, isGenerating: false));
    }
  }

  // Replace the loading bubble with typing animation
  void _replaceLoadingWithTyping(String loadingId, String response) {
    final msgs = List<ChatbotMessageModel>.from(state.messages);
    final idx = msgs.indexWhere((m) => m.id == loadingId);
    if (idx != -1) {
      msgs[idx] = msgs[idx].copyWith(text: '', isLoading: false);
    }

    emit(state.copyWith(
      messages: msgs,
      isTyping: true,
      typingMessageId: loadingId,
      displayedText: '',
      isGenerating: false,
    ));

    _startTypingAnimation(response, loadingId);
  }

  void _removeLoading(String loadingId) {
    final msgs = List<ChatbotMessageModel>.from(state.messages)
      ..removeWhere((m) => m.id == loadingId);
    emit(state.copyWith(messages: msgs, isGenerating: false));
  }

  // ── Typing Animation ─────────────────────────
  void _startTypingAnimation(String response, String messageId) {
    int charCount = 0;
    _typingTimer?.cancel();
    _typingTimer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      charCount++;
      if (charCount <= response.length) {
        emit(state.copyWith(displayedText: response.substring(0, charCount)));
      } else {
        timer.cancel();
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

  // ── TTS ──────────────────────────────────────
  Future<void> toggleSpeak(String text, String messageId) async {
    if (state.isSpeaking && state.currentlySpeakingMessageId == messageId) {
      await _flutterTts.stop();
      emit(state.copyWith(isSpeaking: false, currentlySpeakingMessageId: null));
    } else {
      await _flutterTts.stop();
      // Always clean text before speaking (removes any leftover markdown)
      final cleanText = GeminiService.cleanResponse(text);
      await _setTtsLanguage(_detectLanguage(cleanText));
      emit(state.copyWith(
          isSpeaking: true, currentlySpeakingMessageId: messageId));
      await _flutterTts.speak(cleanText);
    }
  }

  Future<void> stopSpeaking() async {
    if (state.isSpeaking) {
      await _flutterTts.stop();
      emit(state.copyWith(isSpeaking: false, currentlySpeakingMessageId: null));
    }
  }

  // ── STT ──────────────────────────────────────
  Future<void> startListening(void Function(String) onRecognized) async {
    if (state.isGenerating) return;

    await stopSpeaking();
    final available = await _speech.initialize();
    if (available) {
      emit(state.copyWith(isListening: true));
      _speech.listen(
        onResult: (val) => onRecognized(val.recognizedWords),
        listenOptions: stt.SpeechListenOptions(localeId: 'ar-EG'),
      );
    }
  }

  Future<void> stopListening() async {
    if (state.isListening) {
      await _speech.stop();
      emit(state.copyWith(isListening: false));
    }
  }

  // ── Stop generation ───────────────────────────
  void stopGeneration() {
    _typingTimer?.cancel();
    emit(state.copyWith(isGenerating: false, isTyping: false));
  }

  @override
  Future<void> close() {
    _typingTimer?.cancel();
    _speech.stop();
    _flutterTts.stop();
    _geminiService.dispose();
    return super.close();
  }
}
