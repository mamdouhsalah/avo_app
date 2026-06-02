import 'package:avo_app/app/core/services/remote/firebase_consumer.dart';
import 'package:avo_app/app/core/theme/theme_app.dart';
// import 'package:avo_app/app/features/profile/screens/profile_screen.dart';
// import 'package:avo_app/app/features/splash/screens/splash_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:avo_app/app/features/home/data/home_repository.dart';
import 'package:avo_app/app/features/home/data/home_repository_impl.dart';
import 'package:avo_app/app/features/home/logic/home_cubit.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:avo_app/app/core/constants/app_strings.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:avo_app/app/core/routing/app_router.dart';

class MyApp extends StatelessWidget {
  final FirebaseConsumer firebaseConsumer;

  const MyApp({super.key, required this.firebaseConsumer});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return DevicePreview(
          enabled: false,
          builder: (context) => MultiProvider(
            providers: [
              Provider<FirebaseConsumer>.value(value: firebaseConsumer),
              Provider<HomeRepository>(
                create: (context) => HomeRepositoryImpl(
                  consumer: context.read<FirebaseConsumer>(),
                ),
              ),
              BlocProvider<HomeCubit>(
                create: (context) => HomeCubit(
                  repository: context.read<HomeRepository>(),
                )..loadDashboard('1'),
              ),
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