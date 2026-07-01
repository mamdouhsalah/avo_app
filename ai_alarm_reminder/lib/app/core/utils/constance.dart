import 'package:flutter/material.dart';

class AppColors {
  static Color primaryColor = Color(0xFF423783);
  // static Color primaryColor = Color.fromARGB(255, 0, 0, 0);

  static Color white = Color.fromARGB(255, 255, 255, 255);
  static Color black = const Color.fromARGB(255, 13, 13, 13);
  static Color greyBack = const Color.fromARGB(255, 227, 227, 227);
  static Color greyText = const Color.fromARGB(255, 101, 101, 101);

  static const secondaryColor = Color(0xFF03DAC6);
  static const successColor = Color(0xFF4CAF50);
  static const errorColor = Color(0xFFF44336);
  static const background = Color(0xFFF5F7FA);
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
  static const borderColor = Color(0xFFE0E0E0);
}

ThemeData themeData() {
  return ThemeData(
    textTheme: const TextTheme(
        titleSmall: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w300,
            color: Color.fromARGB(255, 8, 125, 221)),
        titleMedium:
            TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600)),
    colorScheme: ColorScheme.light(primary: AppColors.black),
    useMaterial3: true,
  );
}

class CommonStrings {
  static String urlBase = 'https://hobby-back.onrender.com';
}

const Map<String, int> arabicDayToWeekday = {
  'الإثنين': 1,
  'الثلاثاء': 2,
  'الأربعاء': 3,
  'الخميس': 4,
  'الجمعة': 5,
  'السبت': 6,
  'الأحد': 7,
};

const List<String> availableDays = [
  'الإثنين',
  'الثلاثاء',
  'الأربعاء',
  'الخميس',
  'الجمعة',
  'السبت',
  'الأحد',
];
