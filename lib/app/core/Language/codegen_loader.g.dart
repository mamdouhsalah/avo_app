// DO NOT EDIT. This is code generated via package:easy_localization/generate.dart

// ignore_for_file: prefer_single_quotes, avoid_renaming_method_parameters, constant_identifier_names

import 'dart:ui';

import 'package:easy_localization/easy_localization.dart' show AssetLoader;

class CodegenLoader extends AssetLoader{
  const CodegenLoader();

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) {
    return Future.value(mapLocales[locale.toString()]);
  }

  static const Map<String,dynamic> _en = {
  "chatbot": {
    "chatbot_title": "AVO Assistant",
    "chatbot_online": "Online",
    "bot_welcome_msg": "Hello! I am AVO Bot. How can I assist you with your health today?"
  },
  "shared": {
    "save": "Save",
    "cancel": "Cancel",
    "done": "Done"
  }
};
static const Map<String,dynamic> _ar = {
  "chatbot": {
    "chatbot_title": "مساعد أفو",
    "chatbot_online": "متصل",
    "bot_welcome_msg": "أهلاً! أنا مساعد أفو. إزاي أقدر أساعدك في صحتك النهاردة؟"
  },
  "shared": {
    "save": "حفظ",
    "cancel": "إلغاء",
    "done": "تم"
  }
};
static const Map<String, Map<String,dynamic>> mapLocales = {"en": _en, "ar": _ar};
}
