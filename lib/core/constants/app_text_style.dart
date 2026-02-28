// lib/core/constants/app_text_style.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

class AppTextStyle {
  //HEADLINES
  static TextStyle get headline1 => TextStyle(
        fontSize: 32.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.lightText,
      );

  static TextStyle get headline2 => TextStyle(
        fontSize: 28.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.lightText,
      );

  // BODY TEXT
  static TextStyle get bodyLarge => TextStyle(
        fontSize: 18.sp,
        color: AppColors.lightText,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontSize: 16.sp,
        color: AppColors.lightText,
      );

  static TextStyle get bodySmall => TextStyle(
        fontSize: 14.sp,
        color: AppColors.lightSecondaryText,
      );

  // BUTTON TEXT
  static TextStyle get button => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.lightBackground,
      );
}
