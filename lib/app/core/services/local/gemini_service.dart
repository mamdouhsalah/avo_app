import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';

// ─────────────────────────────────────────────
// Result wrapper for typed responses
// ─────────────────────────────────────────────
sealed class GeminiResult {
  const GeminiResult();
}

class GeminiSuccess extends GeminiResult {
  final String text;
  const GeminiSuccess(this.text);
}

class GeminiError extends GeminiResult {
  final String message;
  const GeminiError(this.message);
}

// ─────────────────────────────────────────────
// Main GeminiService (gemini-2.5-flash)
// ─────────────────────────────────────────────
class GeminiService {
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  // Loading state stream — UI can listen to this
  final _loadingController = StreamController<bool>.broadcast();
  Stream<bool> get onLoading => _loadingController.stream;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
      systemInstruction: Content.text(
          'أنت MedBot، مساعد طبي ذكي في تطبيق AVO Assistant. '
          'رد باللغة التي يكتب بها المستخدم: '
          'إذا كتب بالعربية فرد بالعربية المصرية، '
          'وإذا كتب بالإنجليزية فرد بالإنجليزية. '
          '\n\n'
          'قواعد أسلوب الكتابة (صارمة جداً): '
          '1- ممنوع منعاً باتاً استخدام علامة النجمة (*) أو الشباك (#) أو أي علامات تنسيق (Markdown) في ردودك أبدًا. '
          '2- اكتب كنص عادي (Plain Text) كأنك إنسان يتحدث في رسالة نصية، ولا تكتب كذكاء اصطناعي. '
          '3- لا تستخدم القوائم النقطية (Bullet points) أبداً. إذا احتجت للترقيم، استخدم أرقاماً عادية (1، 2، 3). '
          '4- لا تقم بتغليظ الخط (Bold) ولا تمييزه (Italic) إطلاقاً. '
          '5- لا تذكر اسم Google أو Gemini أو كونك نموذج ذكاء اصطناعي. '
          '\n\n'
          'القواعد الطبية: '
          '6- لا تكتب وصفة طبية ولا ترشح أدوية للعلاج أبدًا، انصح المريض بالتوجه للطبيب. '
          '7- إذا أرسل المستخدم صورة (مثل روشتة أو دواء أو تقرير)، قم بتحليلها وتفسير العلاج أو النتائج بشكل مبسط، مع تذكيره دائماً بضرورة مراجعة الطبيب المختص. وإذا كانت الصورة ليس لها علاقة بالطب أو الأدوية، قم بتحليلها والرد عليها بشكل طبيعي، ولكن أضف في نهاية الرد جملة توضح أن هذه الصورة ليس لها علاقة بالمجال الطبي. '
          '8- اسأل المستخدم عن الأعراض (منذ متى بدأت، هل يوجد حرارة أو ألم؟). '
          '9- بناءً على الأعراض أعطه احتمالات (وليس تشخيصًا نهائيًا) واقترح التخصص الطبي الأنسب. '
          '10- إذا ذكر قراءات للضغط أو السكر، حللها وأعطه تنبيهًا إن كانت خطيرة. '
          '11- إذا ذكر أكثر من دواء، تحقق من التفاعلات الدوائية وأخبره بأي تحذيرات. '
          '12- طوارئ 🆘: إذا قال "مش قادر أتنفس" أو "ألم شديد في الصدر"، أعطه خطوات إسعاف فورية واطلب الاتصال بالإسعاف فورًا. '
          '\n\n'
          'الأوامر الخاصة المبرمجة: '
          '- تذكير الدواء: استخدم فقط الصيغة التالية بدون أي نص آخر: call:setMedicationReminder+medName HH:mm '
          '- لجميع الأسئلة الأخرى، أجب بنص عادي فقط بدون أي "call:" أو "+".'),
    );
    _chatSession = _model.startChat();
  }

  Future<GeminiResult> sendMessage(
    String message, {
    Map<String, Function>? functions,
    Uint8List? imageBytes,
  }) async {
    _setLoading(true);
    try {
      final parts = <Part>[
        TextPart(message.trim().isEmpty ? 'اشرح ما في هذه الصورة' : message)
      ];
      if (imageBytes != null) {
        parts.add(DataPart('image/jpeg', imageBytes));
      }

      final response = await _chatSession.sendMessage(Content.multi(parts));
      final raw = response.text ?? '';
      log('GeminiService ▶ $raw');

      final handled = _handleFunctionCall(raw, functions);
      if (handled != null) return GeminiSuccess(cleanResponse(handled));

      return GeminiSuccess(cleanResponse(raw));
    } catch (e, st) {
      log('GeminiService ✖ $e', stackTrace: st);
      return GeminiError(
        'حدث خطأ في الاتصال بالذكاء الاصطناعي\n$e',
      );
    } finally {
      _setLoading(false);
    }
  }

  /// Stream the response token-by-token for a smooth typing feel
  Stream<String> sendMessageStream(String message) async* {
    _setLoading(true);
    try {
      final stream = _model.generateContentStream([Content.text(message)]);
      await for (final chunk in stream) {
        final text = chunk.text ?? '';
        if (text.isNotEmpty) yield text;
      }
    } catch (e, st) {
      log('GeminiService stream ✖ $e', stackTrace: st);
      yield 'حدث خطأ في الاتصال\nAn error occurred.';
    } finally {
      _setLoading(false);
    }
  }

  // ── helpers ──────────────────────────────────
  void _setLoading(bool value) {
    _isLoading = value;
    _loadingController.add(value);
  }

  String? _handleFunctionCall(String text, Map<String, Function>? functions) {
    if (functions == null || !text.contains('call:')) return null;

    final parts = text.split('call:');
    if (parts.length < 2) return null;

    final callText = parts[1].trim();
    final functionParts = callText.split('+');
    final functionName = functionParts[0].trim();

    if (!functions.containsKey(functionName)) return null;

    switch (functionName) {
      case 'setMedicationReminder':
        final paramsText =
            functionParts.length > 1 ? functionParts[1].trim() : '';
        final params = paramsText.split(' ');
        final medName = params.isNotEmpty ? params[0] : 'دواء';
        var time = params.length > 1 ? params[1] : '';
        if (time.isEmpty) {
          time = DateFormat('HH:mm')
              .format(DateTime.now().add(const Duration(minutes: 10)));
        }
        return functions[functionName]!(medName, time) as String;

      case 'showHealthTips':
        return functions[functionName]!() as String;

      case 'parseAnalysisResults':
        final paramsText =
            functionParts.length > 1 ? functionParts[1].trim() : '';
        return functions[functionName]!(paramsText) as String;
    }
    return null;
  }

  void dispose() {
    _loadingController.close();
  }

  // ── Static text cleaner ───────────────────────────────────────────────────
  /// Strips all Markdown formatting and normalises whitespace.
  /// Use before displaying AI text in the UI or passing it to TTS.
  static String cleanResponse(String raw) {
    var text = raw;

    // Remove code fences
    text = text.replaceAll(RegExp(r'```[\s\S]*?```'), '');
    text = text.replaceAll(RegExp(r'`([^`]+)`'), r'\1');

    // Remove bold/italic markers
    text = text.replaceAll(RegExp(r'\*\*(.+?)\*\*'), r'\1');
    text = text.replaceAll(RegExp(r'\*(.+?)\*'), r'\1');
    text = text.replaceAll(RegExp(r'__(.+?)__'), r'\1');
    text = text.replaceAll(RegExp(r'_(.+?)_'), r'\1');

    // Remove bullet list markers
    text = text.replaceAll(RegExp(r'^[\-\*]\s+', multiLine: true), '');

    // Blockquotes
    text = text.replaceAll(RegExp(r'^>\s*', multiLine: true), '');

    // Horizontal rules
    text = text.replaceAll(RegExp(r'^[-_\*]{3,}\s*$', multiLine: true), '');

    // Remove ALL remaining asterisks and hashes just to be absolutely sure
    text = text.replaceAll('*', '');
    text = text.replaceAll('#', '');

    // Collapse 3+ blank lines → 2
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return text.trim();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GeminiTestService (gemini-2.0-flash-lite)
// ─────────────────────────────────────────────────────────────────────────────
class GeminiTestService {
  static String get _apiKey => dotenv.env['GEMINI_TEST_API_KEY'] ?? '';

  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  final _loadingController = StreamController<bool>.broadcast();
  Stream<bool> get onLoading => _loadingController.stream;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  GeminiTestService() {
    _model = GenerativeModel(
      model: 'gemini-2.0-flash-lite',
      apiKey: _apiKey,
      systemInstruction: Content.text(
          'أنت MedBot، مساعد طبي ذكي في تطبيق AVO Assistant. '
          'رد باللغة التي يكتب بها المستخدم: '
          'إذا كتب بالعربية فرد بالعربية المصرية، '
          'وإذا كتب بالإنجليزية فرد بالإنجليزية. '
          '\n\n'
          'قواعد أسلوب الكتابة (صارمة جداً): '
          '1- ممنوع منعاً باتاً استخدام علامة النجمة (*) أو الشباك (#) أو أي علامات تنسيق (Markdown) في ردودك أبدًا. '
          '2- اكتب كنص عادي (Plain Text) كأنك إنسان يتحدث في رسالة نصية، ولا تكتب كذكاء اصطناعي. '
          '3- لا تستخدم القوائم النقطية (Bullet points) أبداً. إذا احتجت للترقيم، استخدم أرقاماً عادية (1، 2، 3). '
          '4- لا تقم بتغليظ الخط (Bold) ولا تمييزه (Italic) إطلاقاً. '
          '5- لا تذكر اسم Google أو Gemini أو كونك نموذج ذكاء اصطناعي. '
          '\n\n'
          'القواعد الطبية: '
          '6- لا تكتب وصفة طبية ولا ترشح أدوية للعلاج أبدًا، انصح المريض بالتوجه للطبيب. '
          '7- إذا أرسل المستخدم صورة (مثل روشتة أو دواء أو تقرير)، قم بتحليلها وتفسير العلاج أو النتائج بشكل مبسط، مع تذكيره دائماً بضرورة مراجعة الطبيب المختص. وإذا كانت الصورة ليس لها علاقة بالطب أو الأدوية، قم بتحليلها والرد عليها بشكل طبيعي، ولكن أضف في نهاية الرد جملة توضح أن هذه الصورة ليس لها علاقة بالمجال الطبي. '
          '8- اسأل المستخدم عن الأعراض (منذ متى بدأت، هل يوجد حرارة أو ألم؟). '
          '9- بناءً على الأعراض أعطه احتمالات (وليس تشخيصًا نهائيًا ) واقترح التخصص الطبي الأنسب. '
          '10- إذا ذكر قراءات للضغط أو السكر، حللها وأعطه تنبيهًا إن كانت خطيرة. '
          '11- إذا ذكر أكثر من دواء، تحقق من التفاعلات الدوائية وأخبره بأي تحذيرات. '
          '12- طوارئ 🆘: إذا قال "مش قادر أتنفس" أو "ألم شديد في الصدر"، أعطه خطوات إسعاف فورية واطلب الاتصال بالإسعاف فورًا. '
          '\n\n'
          'الأوامر الخاصة المبرمجة: '
          '- تذكير الدواء: استخدم فقط الصيغة التالية بدون أي نص آخر: call:setMedicationReminder+medName HH:mm '
          '- لجميع الأسئلة الأخرى، أجب بنص عادي فقط بدون أي "call:" أو "+".'),
    );
    _chatSession = _model.startChat();
  }

  Future<GeminiResult> sendMessage(
    String message, {
    Map<String, Function>? functions,
    Uint8List? imageBytes,
  }) async {
    _setLoading(true);
    try {
      final parts = <Part>[
        TextPart(message.trim().isEmpty ? 'اشرح ما في هذه الصورة' : message)
      ];
      if (imageBytes != null) {
        parts.add(DataPart('image/jpeg', imageBytes));
      }

      final response = await _chatSession.sendMessage(Content.multi(parts));
      final raw = response.text ?? '';
      log('GeminiTestService ▶ $raw');

      final handled = _handleFunctionCall(raw, functions);
      if (handled != null)
        return GeminiSuccess(GeminiService.cleanResponse(handled));

      return GeminiSuccess(GeminiService.cleanResponse(raw));
    } catch (e, st) {
      log('GeminiTestService ✖ $e', stackTrace: st);
      return GeminiError(
        'حدث خطأ في الاتصال بالذكاء الاصطناعي\n$e',
      );
    } finally {
      _setLoading(false);
    }
  }

  // ── helpers ──────────────────────────────────
  void _setLoading(bool value) {
    _isLoading = value;
    _loadingController.add(value);
  }

  String? _handleFunctionCall(String text, Map<String, Function>? functions) {
    if (functions == null || !text.contains('call:')) return null;

    final parts = text.split('call:');
    if (parts.length < 2) return null;

    final callText = parts[1].trim();
    final functionParts = callText.split('+');
    final functionName = functionParts[0].trim();

    if (!functions.containsKey(functionName)) return null;

    switch (functionName) {
      case 'setMedicationReminder':
        final paramsText =
            functionParts.length > 1 ? functionParts[1].trim() : '';
        final params = paramsText.split(' ');
        final medName = params.isNotEmpty ? params[0] : 'دواء';
        var time = params.length > 1 ? params[1] : '';
        if (time.isEmpty) {
          time = DateFormat('HH:mm')
              .format(DateTime.now().add(const Duration(minutes: 10)));
        }
        return functions[functionName]!(medName, time) as String;

      case 'showHealthTips':
        return functions[functionName]!() as String;

      case 'parseAnalysisResults':
        final paramsText =
            functionParts.length > 1 ? functionParts[1].trim() : '';
        return functions[functionName]!(paramsText) as String;
    }
    return null;
  }

  void dispose() {
    _loadingController.close();
  }
}
