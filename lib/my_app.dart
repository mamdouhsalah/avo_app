import 'package:avo_app/app/core/theme/theme_app.dart';
import 'package:avo_app/app/features/home/data/home_data.dart';
import 'package:avo_app/app/features/home/view/screen/home_screen.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

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
          builder: (context) => MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => HomeViewModel()),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: true,
              title: 'AVO Medical App',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: ThemeMode.system,
              home: const HomeScreen(),
              locale: DevicePreview.locale(context),
              builder: DevicePreview.appBuilder,
              useInheritedMediaQuery: true,
            ),
          ),
        );
      },
    );
  }
}
