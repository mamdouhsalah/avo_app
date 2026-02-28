import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

class AppTheme {
  //LIGHT THEME
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.lightPrimary,
    scaffoldBackgroundColor: AppColors.lightBackground,
    cardColor: AppColors.lightCard,
    dividerColor: AppColors.lightDivider,
    iconTheme: IconThemeData(color: AppColors.lightIcon),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: AppColors.lightText),
      bodyMedium: TextStyle(color: AppColors.lightText),
      bodySmall: TextStyle(color: AppColors.lightSecondaryText),
    ),
    colorScheme: ColorScheme.light(
      primary: AppColors.lightPrimary,
      secondary: AppColors.lightButton,
      background: AppColors.lightBackground,
      error: AppColors.error,
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightButton,
        foregroundColor: AppColors.lightBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.circle),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.vMd,
          vertical: AppSpacing.vMd,
        ),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
          foregroundColor: AppColors.lightPrimary, alignment: Alignment.center),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.small),
        borderSide: BorderSide(color: AppColors.lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.small),
        borderSide: BorderSide(color: AppColors.lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.small),
        borderSide: BorderSide(color: AppColors.lightPrimary),
      ),
      hintStyle: TextStyle(color: AppColors.lightSecondaryText),
    ),
  );

  //  DARK THEME
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.darkPrimary,
    scaffoldBackgroundColor: AppColors.darkBackground,
    cardColor: AppColors.darkCard,
    dividerColor: AppColors.darkDivider,
    iconTheme: IconThemeData(color: AppColors.darkIcon),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: AppColors.darkText),
      bodyMedium: TextStyle(color: AppColors.darkText),
      bodySmall: TextStyle(color: AppColors.darkSecondaryText),
    ),
    colorScheme: ColorScheme.dark(
      primary: AppColors.darkPrimary,
      secondary: AppColors.darkButton,
      background: AppColors.darkBackground,
      error: AppColors.error,
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkButton,
        foregroundColor: AppColors.darkText,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.hLg,
          vertical: AppSpacing.vMd,
        ),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.darkPrimary,
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.small),
        borderSide: BorderSide(color: AppColors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.small),
        borderSide: BorderSide(color: AppColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.small),
        borderSide: BorderSide(color: AppColors.darkPrimary),
      ),
      hintStyle: TextStyle(color: AppColors.darkSecondaryText),
    ),
  );
}
