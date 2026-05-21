import 'package:avo_app/app/core/theme/theme_app.dart';
import 'package:avo_app/app/features/appointment/screens/appointment_screen.dart';
import 'package:avo_app/app/features/appointment/screens/detailed_appointmenet.dart';
import 'package:avo_app/app/features/cart/screens/cart_screen.dart';
import 'package:avo_app/app/features/payment/screens/payment_details.dart';
import 'package:avo_app/app/features/payment/screens/payment_methods.dart';
import 'package:avo_app/app/features/schedule/screens/schedule_screen.dart';
import 'package:avo_app/app/features/tracking_order/screens/tracking_screen.dart';
// import 'package:avo_app/app/features/profile/screens/profile_screen.dart';
// import 'package:avo_app/app/features/splash/screens/splash_screen.dart';
import 'package:avo_app/app/features/home/data/home_data.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:avo_app/app/core/constants/app_strings.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:avo_app/app/core/routing/app_router.dart';

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
            child: MaterialApp.router(
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
              routerConfig: AppRouter.router,
              
              builder: DevicePreview.appBuilder,
            ),
          ),
        );
      },
    );
  }
}