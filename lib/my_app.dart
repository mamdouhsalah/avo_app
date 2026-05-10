import 'package:avo_app/app/core/theme/theme_app.dart';
import 'package:avo_app/app/features/profile/screens/profile_screen.dart';
import 'package:avo_app/app/features/splash/screens/splash_screen.dart';
import 'package:avo_app/app/features/home/data/home_data.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:avo_app/app/core/constants/app_strings.dart';

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
          enabled: true,
          builder: (context) => MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => HomeViewModel()),
            ],
            child: MaterialApp(
              // --- إعدادات اللغات بتاعتك ---
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,

              debugShowCheckedModeBanner: false,
              title: AppStrings.appName,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: ThemeMode.system,

              // --- شاشة البداية ---
              home: const ProfileScreen(),

              builder: DevicePreview.appBuilder,
            ),
          ),
        );
      },
    );
  }
}