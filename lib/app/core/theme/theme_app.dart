// lib/app/core/theme/theme_app.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  // ====== LIGHT THEME ======
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // light color scheme
      colorScheme: const ColorScheme.light(
        brightness: Brightness.light,
        primary: AppColors.lightPrimary,
        onPrimary: Colors.white,
        secondary: AppColors.lightIconWithTranceparent,
        onSecondary: AppColors.lightPrimary,
        surface: AppColors.lightBackground,
        onSurface: AppColors.lightText,
        error: AppColors.error,
        onError: Colors.white,
        outline: AppColors.lightBorder,
        outlineVariant: AppColors.lightDivider,
        shadow: AppColors.lightShadow,
      ),

      // light scaffold 
      scaffoldBackgroundColor: AppColors.lightBackground,
      
      // app bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightText,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: AppColors.lightShadow,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.lightText,
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
        ),
        
        iconTheme: IconThemeData(
          color: AppColors.lightIcon,
          size: 24.sp,
        ),
        actionsIconTheme: IconThemeData(
          color: AppColors.lightIcon,
          size: 24.sp,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),

      // light bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightBackground,
        selectedItemColor: AppColors.lightPrimary,
        unselectedItemColor: AppColors.lightSecondaryText,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400),
      ),

      // light navigation bar theme
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightBackground,
        indicatorColor: AppColors.lightIconWithTranceparent,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: AppColors.lightPrimary, size: 24.sp);
          }
          return IconThemeData(color: AppColors.lightSecondaryText, size: 48.sp);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: AppColors.lightPrimary,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            );
          }
          return TextStyle(
            color: AppColors.lightSecondaryText,
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
          );
        }),
      ),

      // light elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightButton,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.lightSecondaryText,
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          minimumSize: Size(0, 52.h), // 🔥 تم التعديل لمنع الـ Overflow جوه الـ Rows
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          textStyle: TextStyle(
            inherit: false,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: .3,
          ),
        ),
      ),

      // light outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.lightPrimary,
          side: const BorderSide(color: AppColors.lightBorder, width: 1.5),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
          minimumSize: Size(0, 52.h), // 🔥 تم التعديل هنا أيضاً
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          textStyle: TextStyle(
            inherit: false,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: .3,
          ),
        ),
      ),
      
      // light text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.lightPrimary,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          textStyle: TextStyle(
            inherit: false,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: .2,
          ),
        ),
      ),

      // light input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightBackground,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.lightDivider, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.lightDivider, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.lightBorder, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: TextStyle(color: AppColors.lightSecondaryText, fontSize: 14.sp),
        labelStyle: TextStyle(color: AppColors.lightSecondaryText, fontSize: 14.sp),
        floatingLabelStyle: TextStyle(
          color: AppColors.lightPrimary,
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
        errorStyle: TextStyle(color: AppColors.error, fontSize: 12.sp),
        prefixIconColor: AppColors.lightIcon,
        suffixIconColor: AppColors.lightSecondaryText,
      ),

      // light card theme
      cardTheme: CardThemeData(
        color: AppColors.lightBackground,
        shadowColor: AppColors.lightShadow,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        margin: EdgeInsets.all(8.w),
      ),

      // light divider theme
      dividerTheme: DividerThemeData(
        color: AppColors.lightDivider,
        thickness: 1.h,
        space: 1.h,
      ),

      // light icon theme
      iconTheme: IconThemeData(
        color: AppColors.lightIcon,
        size: 24.sp,
      ),

      // light list tile theme
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.lightIcon,
        textColor: AppColors.lightText,
        tileColor: AppColors.lightBackground,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      ),

      // light snack bar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.lightText,
        contentTextStyle: TextStyle(color: Colors.white, fontSize: 14.sp),
        actionTextColor: AppColors.lightPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // light floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.lightIconWithTranceparent,
        foregroundColor: AppColors.lightButton,
        elevation: 4,
        highlightElevation: 8,
        shape: const CircleBorder(),
      ),
    );
  }

  // ====== DARK THEME ======
  static ThemeData get darkTheme {
    const darkBg = AppColors.darkBackground;
    const darkSurface = Color(0xFF1E1E1E); // لتبطين الكروت والقوائم في الدارك مودي
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      
      // dark color scheme
      colorScheme: const ColorScheme.dark(
        brightness: Brightness.dark,
        primary: AppColors.darkPrimary,
        onPrimary: Colors.white,
        secondary: AppColors.darkPrimary,
        onSecondary: Colors.white,
        surface: darkBg,
        onSurface: AppColors.darkText,
        error: AppColors.error,
        outline: AppColors.darkBorder,
        outlineVariant: AppColors.darkDivider,
      ),

      // dark app bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: darkBg,
        foregroundColor: AppColors.darkText,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.darkText,
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(
          color: AppColors.darkIcon,
          size: 24.sp,
        ),
        actionsIconTheme: IconThemeData(
          color: AppColors.darkIcon,
          size: 24.sp,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),

      // dark bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkBg,
        selectedItemColor: AppColors.darkPrimary,
        unselectedItemColor: AppColors.darkSecondaryText,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400),
      ),

      // dark navigation bar theme
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkBg,
        indicatorColor: AppColors.darkPrimary.withOpacity(0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: AppColors.darkPrimary, size: 24.sp);
          }
          return IconThemeData(color: AppColors.darkSecondaryText, size: 48.sp);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: AppColors.darkPrimary,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            );
          }
          return TextStyle(
            color: AppColors.darkSecondaryText,
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
          );
        }),
      ),

      // dark elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.darkSecondaryText,
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          minimumSize: Size(0, 52.h), // 🔥 تم التعديل لحل الـ Overflow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          textStyle: TextStyle(
            inherit: false,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: .3,
          ),
        ),
      ),

      // dark outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkPrimary,
          side: const BorderSide(color: AppColors.darkBorder, width: 1.5),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
          minimumSize: Size(0, 52.h), // 🔥 تم التعديل هنا أيضاً
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          textStyle: TextStyle(
            inherit: false,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: .3,
          ),
        ),
      ),

      // dark text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkPrimary,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          textStyle: TextStyle(
            inherit: false,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: .2,
          ),
        ),
      ),

      // dark input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.darkDivider, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.darkDivider, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.darkPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: TextStyle(color: AppColors.darkSecondaryText, fontSize: 14.sp),
        labelStyle: TextStyle(color: AppColors.darkSecondaryText, fontSize: 14.sp),
        floatingLabelStyle: TextStyle(
          color: AppColors.darkPrimary,
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
        errorStyle: TextStyle(color: AppColors.error, fontSize: 12.sp),
        prefixIconColor: AppColors.darkIcon,
        suffixIconColor: AppColors.darkSecondaryText,
      ),

      // dark card theme
      cardTheme: CardThemeData(
        color: darkSurface,
        shadowColor: Colors.black45,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        margin: EdgeInsets.all(8.w),
      ),

      // dark divider theme
      dividerTheme: DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 1.h,
        space: 1.h,
      ),

      // dark icon theme
      iconTheme: IconThemeData(
        color: AppColors.darkIcon,
        size: 24.sp,
      ),

      // dark list tile theme
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.darkIcon,
        textColor: AppColors.darkText,
        tileColor: darkSurface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      ),

      // dark snack bar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkSurface,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        actionTextColor: AppColors.darkPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // dark floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.darkPrimary.withOpacity(0.15),
        foregroundColor: AppColors.darkPrimary,
        elevation: 4,
        highlightElevation: 8,
        shape: const CircleBorder(),
      ),
    );
  }
}