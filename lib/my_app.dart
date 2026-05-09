import 'package:avo_app/app/core/constants/app_strings.dart';
import 'package:avo_app/app/core/theme/theme_app.dart';
import 'package:avo_app/app/features/onboard/screens/onboard_screen.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app/features/chatbot/screens/chat_screen.dart';
import 'app/features/reminder/screens/reminder_screen.dart';

import 'package:easy_localization/easy_localization.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return DevicePreview(
          // enabled: !kReleaseMode,
          enabled: false,
          builder: (context) => MaterialApp(

            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,

            debugShowCheckedModeBanner: true,
            title: AppStrings.appName,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            //home: const OnboardScreen(),
            home: const ChatScreen(),
            // locale: DevicePreview.locale(context),
            builder: DevicePreview.appBuilder,
            useInheritedMediaQuery: true,
          ),
        );
      },
    );
  }
}
