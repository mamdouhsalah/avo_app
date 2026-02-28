import 'package:flutter/material.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/theme_app.dart';
import 'features/onboard/screens/onboard_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: true,
        title: AppStrings.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: OnboardScreen());
  }
}
