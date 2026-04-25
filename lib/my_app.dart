import 'package:avo_app/app/core/constants/app_strings.dart';
import 'package:avo_app/app/core/theme/theme_app.dart';
import 'package:avo_app/app/features/appointment/screens/appointment_screen.dart';
import 'package:avo_app/app/features/appointment/screens/detailed_appointmenet.dart';
import 'package:avo_app/app/features/cart/screens/cart_screen.dart';
import 'package:avo_app/app/features/payment/screens/payment_details.dart';
import 'package:avo_app/app/features/payment/screens/payment_methods.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
          enabled: !kReleaseMode,
          builder: (context) => MaterialApp(
            debugShowCheckedModeBanner: true,
            title: AppStrings.appName,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.dark,
            home: const CartScreen(),
            locale: DevicePreview.locale(context),
            builder: DevicePreview.appBuilder,
            useInheritedMediaQuery: true,
          ),
        );
      },
    );
  }
}
