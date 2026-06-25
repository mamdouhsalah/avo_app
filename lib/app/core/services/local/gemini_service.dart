// import 'dart:developer';
// import 'package:google_generative_ai/google_generative_ai.dart';
// import 'package:intl/intl.dart';

// class GeminiService {
//   static const String _apiKey =
//       'AIzaSyBR3i46-F9NZKCRTeWKA_1WLjiizCtsv70'; // Replace with your API key
//   late final GenerativeModel _model;
//   late final ChatSession _chatSession;

//   GeminiService() {
//     _model = GenerativeModel(
//       model: 'gemini-2.0-flash-lite',
//       apiKey: _apiKey,
//       systemInstruction: Content.text(
//           "أنت MedBot، مساعد طبي في تطبيق MedSense. "
//           "لا تذكر Gemini أو Google أبدًا. "
//           "رد باللغة العربية المصرية فقط. "
//           "You are a medical analysis assistant وقدم استشارات طبية دقيقة أجب باللغة العربية العامية اشرح بالتفصيل الممل لكل تحليل بالأرقام بطريقة لبقة و اقترح نصائح للمريض"
//           "For specific commands, use the '+' sign as a delimiter to separate the command from its parameters or additional text: "
//           "- If the user says 'set a medication reminder' or similar (e.g., 'remind me to take paracetamol at 8:00 PM'), return 'call:setMedicationReminder+medName time' (e.g., 'call:setMedicationReminder+paracetamol 8:00 PM'). Extract the medication name and time from the input. Use 24-hour format (e.g., '8:00 AM' for 8:00 PM). If no time is provided, assume 10 minutes from now and estimate it. If no medication name is provided, use 'دواء'. "
//           "- If the user says 'show health tips' or similar, return 'call:showHealthTips+' followed by health tips in Egyptian Arabic, each on a new line"
//           "- For all other queries, provide a text response without 'call:' or '+' signs."),
//     );
//     _chatSession = _model.startChat();
//   }

//   Future<String> sendMessage(String message,
//       {Map<String, Function>? functions}) async {
//     final content = Content.text(message);
//     final response = await _chatSession.sendMessage(content);
//     final responseText = response.text ?? '';
//     log("Response from AI: $responseText");

//     if (functions != null && responseText.contains('call:')) {
//       final parts = responseText.split('call:');
//       if (parts.length > 1) {
//         final callText = parts[1].trim();
//         final functionParts = callText.split('+');
//         final functionName = functionParts[0].trim();

//         if (functions.containsKey(functionName)) {
//           if (functionName == 'setMedicationReminder') {
//             final paramsText =
//                 functionParts.length > 1 ? functionParts[1].trim() : '';
//             final params = paramsText.split(' ');
//             String medName = params.isNotEmpty ? params[0] : 'دواء';
//             String time = params.length > 1 ? params[1] : '';

//             if (time.isEmpty) {
//               final now = DateTime.now().add(const Duration(minutes: 10));
//               time = DateFormat('HH:mm').format(now);
//             }

//             final functionResult =
//                 functions[functionName]!(medName, time) as String;
//             return functionResult;
//           } else if (functionName == 'showHealthTips') {
//             final functionResult = functions[functionName]!() as String;
//             return functionResult; // Return tips as part of the response
//           }
//         }
//       }
//     }
//     return responseText;
//   }
// }
import 'dart:developer';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';

class GeminiService {
  static const String _apiKey = 'AIzaSyAwxcmEGsiOUzEbhtx42z5fHx_RTVrMFb8';
  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
      // systemInstruction: Content.text(
      //     "أنت MedBot، مساعد طبي في تطبيق MedSense. "
      //     "لا تذكر Gemini أو Google أبدًا. "
      //     "رد باللغة العربية المصرية فقط، وقدم إجابات طبية مختصرة ودقيقة بدون تفاصيل غير ضرورية. "
      //     "You are a medical analysis assistant وقدم استشارات طبية دقيقة أجب باللغة العربية العامية بدون النظر في البيانات الشخصية و التاريخ و الوقت و اي اكواد و اشرح بالتفصيل الممل بالارقام كامله بطريقة لبقة و اقترح نصائح للمريض "
      //     "For specific commands, use the '+' sign as a delimiter to separate the command from its parameters or additional text: "
      //     "- If the user says 'set a medication reminder' or similar (e.g., 'remind me to take paracetamol at 8:00 PM'), return 'call:setMedicationReminder+medName time' (e.g., 'call:setMedicationReminder+paracetamol 8:00 PM'). Extract the medication name and time from the input. Use 24-hour format (e.g., '20:00' for 8:00 PM). If no time is provided, assume 10 minutes from now and estimate it. If no medication name is provided, use 'دواء'. "
      //     "- If the user says 'show health tips' or similar, return 'call:showHealthTips+' followed by health tips in Egyptian Arabic, each on a new line "
      //     "- If the user says 'Parse the following analysis result' or similar, return 'call:parseAnalysisResults+analysisName|stateName|value|normalLimits|description'. Choose the most appropriate analysisName from the provided list, extract the stateName, value (as a number), normalLimits, and description from the analysis text. "
      //     "- For all other queries, provide a text response without 'call:' or '+' signs."),
      systemInstruction: Content.text(
          "أنت MedBot، مساعد طبي ذكي في تطبيق MedSense. "
          "رد باللغة العربية المصرية فقط، وقدم إجابات طبية دقيقة وتعاطف مع المريض. "
          "أهم القواعد التي يجب الالتزام بها: "
          "1- لا تكتب أي وصفة طبية ولا ترشح أدوية للعلاج أبدًا، انصحه فقط بالتوجه للطبيب. "
          "2- اسأل المستخدم عن الأعراض، منذ متى بدأت، هل يوجد حرارة؟ هل يوجد ألم؟ "
          "3- بناءً على الأعراض، أعطه احتمالات (وليس تشخيص نهائي ⚠️)، واقترح التخصص الطبي الأنسب (مثل: قلب، باطنة، جلدية، إلخ). "
          "4- إذا ذكر المستخدم قراءات للضغط أو السكر، حللها وأعطه تنبيهًا إذا كانت خطيرة (Smart Alerts). "
          "5- إذا ذكر أكثر من دواء، تأكد من عدم وجود تفاعلات دوائية (Drug Interaction Checker) وأخبره بالتحذيرات إن وجدت. "
          "6- حالة الطوارئ (Emergency Mode 🆘): إذا قال المريض 'مش قادر أتنفس' أو 'ألم شديد في الصدر'، أعطه خطوات إسعافات فورية واطلب منه الاتصال بالإسعاف فورًا. "
          "7- إذا طلب المستخدم قراءة تقرير أو روشتة، اشرح له محتوياتها بتبسيط ووجهه للطبيب المختص. "
          "8- إذا طلب تذكيرًا بدواء، استخدم 'call:setMedicationReminder+medName time' (e.g. 'call:setMedicationReminder+paracetamol 20:00'). "
          "9- لا تذكر Gemini أو Google أبدًا. "
          "- For all other queries, provide a text response without 'call:' or '+' signs."),
    );
    _chatSession = _model.startChat();
  }

  Future<String> sendMessage(String message,
      {Map<String, Function>? functions}) async {
    final content = Content.text(message);

    try {
      final response = await _chatSession.sendMessage(content);
      final responseText = response.text ?? '';

      log("Response from AI: $responseText");

      if (functions != null && responseText.contains('call:')) {
        final parts = responseText.split('call:');

        if (parts.length > 1) {
          final callText = parts[1].trim();
          final functionParts = callText.split('+');
          final functionName = functionParts[0].trim();

          if (functions.containsKey(functionName)) {
            if (functionName == 'setMedicationReminder') {
              final paramsText =
                  functionParts.length > 1 ? functionParts[1].trim() : '';

              final params = paramsText.split(' ');

              String medName = params.isNotEmpty ? params[0] : 'دواء';
              String time = params.length > 1 ? params[1] : '';

              if (time.isEmpty) {
                final now = DateTime.now().add(const Duration(minutes: 10));
                time = DateFormat('HH:mm').format(now);
              }

              final result = functions[functionName]!(medName, time) as String;

              return result;
            } else if (functionName == 'showHealthTips') {
              final result = functions[functionName]!() as String;

              return result;
            } else if (functionName == 'parseAnalysisResults') {
              final paramsText =
                  functionParts.length > 1 ? functionParts[1].trim() : '';

              final result = functions[functionName]!(paramsText) as String;

              return result;
            }
          }
        }
      }

      return responseText;
    } catch (e) {
      log("Gemini Error: $e");
      return "حدث خطأ في الاتصال بالذكاء الاصطناعي";
    }
  }
}

class GeminiTestService {
  static const String _apiKey = 'AIzaSyBR3i46-F9NZKCRTeWKA_1WLjiizCtsv70';
  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  GeminiTestService() {
    _model = GenerativeModel(
      model: 'gemini-2.0-flash-lite',
      apiKey: _apiKey,
      // systemInstruction: Content.text(
      //     "أنت MedBot، مساعد طبي في تطبيق MedSense. "
      //     "لا تذكر Gemini أو Google أبدًا. "
      //     "رد باللغة العربية المصرية فقط، وقدم إجابات طبية مختصرة ودقيقة بدون تفاصيل غير ضرورية. "
      //     "You are a medical analysis assistant وقدم استشارات طبية دقيقة أجب باللغة العربية العامية بدون النظر في البيانات الشخصية و التاريخ و الوقت و اي اكواد و اشرح بالتفصيل الممل بالارقام كامله بطريقة لبقة و اقترح نصائح للمريض "
      //     "For specific commands, use the '+' sign as a delimiter to separate the command from its parameters or additional text: "
      //     "- If the user says 'set a medication reminder' or similar (e.g., 'remind me to take paracetamol at 8:00 PM'), return 'call:setMedicationReminder+medName time' (e.g., 'call:setMedicationReminder+paracetamol 8:00 PM'). Extract the medication name and time from the input. Use 24-hour format (e.g., '20:00' for 8:00 PM). If no time is provided, assume 10 minutes from now and estimate it. If no medication name is provided, use 'دواء'. "
      //     "- If the user says 'show health tips' or similar, return 'call:showHealthTips+' followed by health tips in Egyptian Arabic, each on a new line "
      //     "- If the user says 'Parse the following analysis result' or similar, return 'call:parseAnalysisResults+analysisName|stateName|value|normalLimits|description'. Choose the most appropriate analysisName from the provided list, extract the stateName, value (as a number), normalLimits, and description from the analysis text. "
      //     "- For all other queries, provide a text response without 'call:' or '+' signs."),
      systemInstruction: Content.text(
          "أنت MedBot، مساعد طبي في تطبيق MedSense. "
          "لا تذكر Gemini أو Google أبدًا. "
          // "رد باللغة العربية المصرية فقط، وقدم إجابات طبية كاملة ودقيقة بدون تفاصيل غير ضرورية. "
          // "You are a medical analysis assistant وقدم استشارات طبية دقيقة أجب باللغة العربية العامية بدون النظر في البيانات الشخصية و التاريخ و الوقت و اي اكواد و اشرح بالتفصيل الممل بالارقام و شرح نوع التحليل بطريقة لبقة و اقترح نصائح للمريض "
          "For specific commands, use the '+' sign as a delimiter to separate the command from its parameters or additional text: "
          "- If the user says 'set a medication reminder' or similar (e.g., 'remind me to take paracetamol at 8:00 PM'), return 'call:setMedicationReminder+medName time' (e.g., 'call:setMedicationReminder+paracetamol 8:00 PM'). Extract the medication name and time from the input. Use 24-hour format (e.g., '20:00' for 8:00 PM). If no time is provided, assume 10 minutes from now and estimate it. If no medication name is provided, use 'دواء'. "
          "- If the user says 'show health tips' or similar, return 'call:showHealthTips+' followed by health tips in Egyptian Arabic, each on a new line "
          // "- If the user says 'Parse the following analysis result' or similar, return 'call:parseAnalysisResults+analysisName|stateName|value|normalLimits|description[;analysisName|stateName|value|normalLimits|description]*'. Determine the analysisName (e.g., 'Blood Test', 'Urine Analysis') based on the content. Extract each test result as a stateName (e.g., 'Hemoglobin'), value (as a number), normalLimits (e.g., '12-16 g/dL'), and description (e.g., 'Normal level'). Include multiple results separated by ';' if the analysis contains multiple tests. "
          "- For all other queries, provide a text response without 'call:' or '+' signs."),
    );
    _chatSession = _model.startChat();
  }

  Future<String> sendMessage(String message,
      {Map<String, Function>? functions}) async {
    final content = Content.text(message);
    final response = await _chatSession.sendMessage(content);
    final responseText = response.text ?? '';
    log("Response from AI: $responseText");

    if (functions != null && responseText.contains('call:')) {
      final parts = responseText.split('call:');
      if (parts.length > 1) {
        final callText = parts[1].trim();
        final functionParts = callText.split('+');
        final functionName = functionParts[0].trim();

        if (functions.containsKey(functionName)) {
          if (functionName == 'setMedicationReminder') {
            final paramsText =
                functionParts.length > 1 ? functionParts[1].trim() : '';
            final params = paramsText.split(' ');
            String medName = params.isNotEmpty ? params[0] : 'دواء';
            String time = params.length > 1 ? params[1] : '';

            if (time.isEmpty) {
              final now = DateTime.now().add(const Duration(minutes: 10));
              time = DateFormat('HH:mm').format(now);
            }

            final functionResult =
                functions[functionName]!(medName, time) as String;
            return functionResult;
          } else if (functionName == 'showHealthTips') {
            final functionResult = functions[functionName]!() as String;
            return functionResult;
          } else if (functionName == 'parseAnalysisResults') {
            final paramsText =
                functionParts.length > 1 ? functionParts[1].trim() : '';
            final functionResult =
                functions[functionName]!(paramsText) as String;
            return functionResult;
          }
        }
      }
    }
    return responseText;
  }
}
