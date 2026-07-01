import 'dart:developer';

import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:ai_alarm_reminder/app/core/utils/constance.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import '../../core/services/gemini_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final List<types.Message> _messages = [];
  final _user = const types.User(id: 'user');
  final _ai = const types.User(id: 'ai');
  late GeminiService _geminiService;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocusNode = FocusNode();
  AnimationController? _typingAnimationController;
  Animation<double>? _typingAnimation;
  String _currentAiResponse = '';
  String _displayedText = '';
  bool _isTyping = false;
  String? _typingMessageId;

  // Voice and UX state
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isListening = false;
  bool _isGenerating = false;
  bool _isSpeechInitialized = false;
  // Track which message is currently being spoken
  String? _currentlySpeakingMessageId;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _geminiService = GeminiService();
    _addWelcomeMessage();
    _initVoice();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _textFieldFocusNode.requestFocus();
    });
  }

  Future<void> _initVoice() async {
    _isSpeechInitialized = await _speech.initialize();
    await _flutterTts.setLanguage("ar-EG");
    await _flutterTts.setSpeechRate(0.5);
    _flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _currentlySpeakingMessageId = null;
        });
      }
    });
    _flutterTts.setCancelHandler(() {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _currentlySpeakingMessageId = null;
        });
      }
    });
    setState(() {});
  }

  @override
  void dispose() {
    _typingAnimationController?.dispose();
    _textController.dispose();
    _textFieldFocusNode.dispose();
    _speech.stop();
    _flutterTts.stop();
    super.dispose();
  }

  void _addWelcomeMessage() {
    final welcomeMessage = types.TextMessage(
      author: _ai,
      id: const Uuid().v4(),
      text: 'ازيك انا MedSense أقدر أساعدك ازاي النهاردة؟',
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    setState(() {
      _messages.add(welcomeMessage);
    });
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _startTypingAnimation(String response, String messageId) {
    _currentAiResponse = response;
    _displayedText = '';
    _isTyping = true;
    _typingMessageId = messageId;

    _typingAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: response.length * 30),
    );

    _typingAnimation = Tween<double>(begin: 0, end: response.length.toDouble())
        .animate(_typingAnimationController!)
      ..addListener(() {
        setState(() {
          int charCount = _typingAnimation!.value.floor();
          _displayedText = _currentAiResponse.substring(0, charCount);
        });
      })
      ..addStatusListener((status) async {
        if (status == AnimationStatus.completed) {
          setState(() {
            int index =
                _messages.indexWhere((msg) => msg.id == _typingMessageId);
            if (index != -1 && _messages[index] is types.TextMessage) {
              _messages[index] = (_messages[index] as types.TextMessage)
                  .copyWith(text: _currentAiResponse);
            }
            _isTyping = false;
            _typingMessageId = null;
            _displayedText = '';
          });
          _currentAiResponse = '';
          _typingAnimationController?.dispose();
          _typingAnimationController = null;
        }
      });

    _typingAnimationController!.forward();
  }

  Future<void> _toggleSpeak(String text, String messageId) async {
    if (_isSpeaking && _currentlySpeakingMessageId == messageId) {
      // Stop speaking if same message
      await _flutterTts.stop();
      setState(() {
        _isSpeaking = false;
        _currentlySpeakingMessageId = null;
      });
    } else {
      // Stop any previous speech first
      await _flutterTts.stop();
      setState(() {
        _isSpeaking = true;
        _currentlySpeakingMessageId = messageId;
      });
      await _flutterTts.speak(text);
    }
  }

  Future<void> _stopSpeaking() async {
    await _flutterTts.stop();
    if (mounted) {
      setState(() {
        _isSpeaking = false;
        _currentlySpeakingMessageId = null;
      });
    }
  }

  void _stopGeneration() {
    setState(() {
      _isGenerating = false;
      _isTyping = false;
      if (_typingAnimationController != null) {
        _typingAnimationController!.stop();
      }
      _geminiService = GeminiService();
    });
  }

  Future<void> _handleSendPressed(types.PartialText message) async {
    // Stop any ongoing speech or listening before sending
    await _stopSpeaking();
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    }

    final textMessage = types.TextMessage(
      author: _user,
      id: const Uuid().v4(),
      text: message.text,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    _addMessage(textMessage);

    setState(() {
      _isGenerating = true;
    });

    final functions = {
      'showHealthTips': () {
        _showHealthTips();
        return 'Health tips displayed!';
      },
      'setMedicationReminder': (String medName, String time) {
        _showReminderConfirmationSheet(medName: medName, time: time);
        return '';
      },
    };

    try {
      final response =
          await _geminiService.sendMessage(message.text, functions: functions);

      if (!mounted || !_isGenerating) return;

      if (response.isNotEmpty) {
        final messageId = const Uuid().v4();
        final aiMessage = types.TextMessage(
          author: _ai,
          id: messageId,
          text: '',
          createdAt: DateTime.now().millisecondsSinceEpoch,
        );
        _addMessage(aiMessage);
        _startTypingAnimation(response, messageId);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  void _listen() async {
    if (_isGenerating) return; // Don't allow recording while generating

    if (!_isListening) {
      await _stopSpeaking(); // Stop any reading before listening
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _textController.text = val.recognizedWords;
          }),
          localeId: "ar-EG",
          // Stop listening when final result is received and auto-send
          onSoundLevelChange: (level) {},
        );
      }
    } else {
      setState(() => _isListening = false);
      await _speech.stop();
      if (_textController.text.isNotEmpty) {
        _handleSendPressed(types.PartialText(text: _textController.text));
        _textController.clear();
      }
    }
  }

  void _showHealthTips() async {
    final response = await _geminiService.sendMessage("show health tips");
    List<String> tips = [];

    if (response.contains('call:showHealthTips')) {
      final tipsText = response.split('call:showHealthTips+')[1].trim();
      tips = tipsText.split('\n').where((tip) => tip.isNotEmpty).toList();
    } else {
      tips = [
        "شرب مية كتير كل يوم",
        "نام 8 ساعات بالليل",
        "تمرن نص ساعة يوميًا"
      ];
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'نصايح صحية',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 16),
            ...tips.map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text('• $tip', style: const TextStyle(fontSize: 16)),
                )),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('قفل',
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReminderConfirmationSheet({
    required String medName,
    required String time,
  }) {
    TextEditingController medNameController =
        TextEditingController(text: medName);
    TextEditingController timeController = TextEditingController(text: time);
    int doseFrequency = 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: 400,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade50, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'تأكيد التذكير بالدواء',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: medNameController,
                decoration: InputDecoration(
                  labelText: 'اسم الدواء',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: timeController,
                decoration: InputDecoration(
                  labelText: 'الوقت (HH:MM)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'عدد الجرعات في اليوم:',
                style: TextStyle(fontSize: 16),
              ),
              Row(
                children: [
                  Radio<int>(
                    value: 1,
                    groupValue: doseFrequency,
                    onChanged: (value) {
                      setModalState(() {
                        doseFrequency = value!;
                      });
                    },
                  ),
                  const Text('مرة واحدة'),
                  Radio<int>(
                    value: 3,
                    groupValue: doseFrequency,
                    onChanged: (value) {
                      setModalState(() {
                        doseFrequency = value!;
                      });
                    },
                  ),
                  const Text('3 مرات'),
                ],
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  onPressed: () {
                    _setMedicationReminder(
                      medName: medNameController.text,
                      time: timeController.text,
                      doseFrequency: doseFrequency,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('تم',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _setMedicationReminder({
    required String medName,
    required String time,
    required int doseFrequency,
  }) async {
    DateTime baseTime;
    try {
      final now = DateTime.now();
      final parsedTime = DateFormat('HH:mm').parse(time);
      baseTime = DateTime(
        now.year,
        now.month,
        now.day,
        parsedTime.hour,
        parsedTime.minute,
      );
      if (baseTime.isBefore(now)) {
        baseTime = baseTime.add(const Duration(days: 1));
      }
    } catch (e) {
      baseTime = DateTime.now().add(const Duration(minutes: 10));
      log("Error parsing time: $e, using fallback time");
    }

    List<DateTime> reminderTimes = [];
    if (doseFrequency == 1) {
      reminderTimes.add(baseTime);
    } else if (doseFrequency == 3) {
      reminderTimes.add(baseTime);
      reminderTimes.add(baseTime.add(const Duration(hours: 8)));
      reminderTimes.add(baseTime.add(const Duration(hours: 16)));
    }

    for (var reminderTime in reminderTimes) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000 +
              reminderTimes.indexOf(reminderTime),
          channelKey: 'med_reminder_channel',
          title: 'تذكير بالدواء: $medName',
          body: 'حان وقت أخد دوائك "$medName"!',
          wakeUpScreen: true,
          category: NotificationCategory.Reminder,
        ),
        schedule: NotificationCalendar.fromDate(date: reminderTime),
      );
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.white,
        content: Text(
          'تم وضع تذكير لـ "$medName" ${doseFrequency == 1 ? 'مرة واحدة' : '3 مرات'} في اليوم',
          style: const TextStyle(color: Colors.black),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayMessages = _messages.map((message) {
      if (_isTyping &&
          message is types.TextMessage &&
          message.id == _typingMessageId) {
        return message.copyWith(text: _displayedText);
      }
      return message;
    }).toList();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'MedBot',
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
        ),
        actions: [
          if (_isGenerating || _isTyping)
            IconButton(
              icon: const Icon(Icons.stop_circle, color: Colors.red),
              onPressed: _stopGeneration,
            ),
        ],
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_isGenerating)
              const LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
              ),
            Expanded(
              child: Chat(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.manual,
                messages: displayMessages,
                bubbleRtlAlignment: BubbleRtlAlignment.right,
                onSendPressed: (partialText) {
                  if (_isListening) {
                    _speech.stop();
                    setState(() => _isListening = false);
                  }
                  _handleSendPressed(partialText);
                },
                user: _user,
                textMessageBuilder: (types.TextMessage message,
                    {required int messageWidth, required bool showName}) {
                  final isAi = message.author.id == _ai.id;
                  final isSpeakingThis =
                      _isSpeaking && _currentlySpeakingMessageId == message.id;
                  return Column(
                    crossAxisAlignment: isAi
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isAi
                              ? const Color.fromARGB(255, 230, 230, 230)
                              : AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          message.text,
                          style: TextStyle(
                            color: isAi ? Colors.black : Colors.white,
                            fontFamily: 'Cairo',
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (isAi && message.text.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: GestureDetector(
                            onTap: () => _toggleSpeak(message.text, message.id),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSpeakingThis
                                    ? Colors.red.shade50
                                    : Colors.teal.shade50,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSpeakingThis
                                      ? Colors.red.shade200
                                      : Colors.teal.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isSpeakingThis
                                        ? Icons.stop_circle_rounded
                                        : Icons.play_circle_fill_rounded,
                                    color: isSpeakingThis
                                        ? Colors.red
                                        : Colors.teal,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isSpeakingThis ? 'إيقاف' : 'استمع',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 12,
                                      color: isSpeakingThis
                                          ? Colors.red
                                          : Colors.teal,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
                customBottomWidget: _buildCustomTextField(),
                dateFormat: DateFormat('dd/MM/yyyy'),
                timeFormat: DateFormat('HH:mm'),
                theme: DefaultChatTheme(
                  primaryColor: AppColors.primaryColor,
                  secondaryColor: const Color.fromARGB(255, 230, 230, 230),
                  userAvatarNameColors: [Colors.teal.shade800],
                  inputBackgroundColor: Colors.white,
                  inputTextColor: Colors.black,
                  messageBorderRadius: 15,
                  inputPadding: const EdgeInsets.all(0),
                  inputMargin: const EdgeInsets.all(0),
                  sentMessageBodyTextStyle: const TextStyle(
                      fontFamily: 'Cairo', fontSize: 16, color: Colors.white),
                  receivedMessageBodyTextStyle:
                      const TextStyle(fontFamily: 'Cairo', fontSize: 16),
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTextField() {
    return Material(
      elevation: 5,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: const BoxDecoration(color: Colors.white),
        child: Row(
          children: [
            GestureDetector(
              onTap: _listen,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color:
                      _isListening ? Colors.red.shade50 : Colors.teal.shade50,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _isListening ? Colors.red : Colors.teal,
                    width: _isListening ? 2 : 1,
                  ),
                ),
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: _isListening ? Colors.red : Colors.teal,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _textController,
                focusNode: _textFieldFocusNode,
                decoration: InputDecoration(
                  fillColor: AppColors.greyBack,
                  filled: true,
                  hintText:
                      _isListening ? 'جاري الاستماع...' : 'اسألني أي حاجة...',
                  hintStyle: TextStyle(
                      color: _isListening ? Colors.red : Colors.grey[600],
                      fontFamily: 'Cairo'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                style: const TextStyle(fontFamily: 'Cairo'),
                onSubmitted: (text) {
                  if (text.isNotEmpty && !_isGenerating) {
                    _handleSendPressed(types.PartialText(text: text));
                    _textController.clear();
                    _textFieldFocusNode.requestFocus();
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                if (_textController.text.isNotEmpty && !_isGenerating) {
                  _handleSendPressed(
                      types.PartialText(text: _textController.text));
                  _textController.clear();
                  _textFieldFocusNode.requestFocus();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(FontAwesomeIcons.solidPaperPlane,
                    color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GradientGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.blue.withOpacity(0.5),
          Colors.purple.withOpacity(0.5),
          Colors.pink.withOpacity(0.5),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(30),
      ));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
