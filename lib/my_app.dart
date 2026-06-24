import 'package:avo_app/app/core/constants/app_strings.dart';
import 'package:avo_app/app/core/routing/app_router.dart';
import 'package:avo_app/app/core/services/remote/firebase_consumer.dart';
import 'package:avo_app/app/core/theme/theme_app.dart';
import 'package:avo_app/app/core/theme/theme_cubit.dart';
import 'package:avo_app/app/features/admin/data/admin_repository.dart';
import 'package:avo_app/app/features/admin/data/admin_repository_impl.dart';
import 'package:avo_app/app/features/admin/logic/admin_cubit.dart';
import 'package:avo_app/app/features/home/data/home_repository.dart';
import 'package:avo_app/app/features/home/data/home_repository_impl.dart';
import 'package:avo_app/app/features/home/logic/home_cubit.dart';
import 'package:avo_app/app/features/auth/data/auth_repository.dart';
import 'package:avo_app/app/features/auth/data/auth_repository_impl.dart';
import 'package:avo_app/app/features/auth/logic/auth_cubit.dart';
import 'package:avo_app/app/features/profile/data/profile_repository.dart';
import 'package:avo_app/app/features/profile/data/profile_repository_impl.dart';
import 'package:avo_app/app/features/profile/logic/profile_cubit.dart';
import 'package:avo_app/app/features/splash/logic/splash_cubit.dart';
import 'package:device_preview/device_preview.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

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
              Provider<AuthRepository>(
                create: (context) => AuthRepositoryImpl(
                  consumer: context.read<FirebaseConsumer>(),
                ),
              ),
              Provider<ProfileRepository>(
                create: (context) => ProfileRepositoryImpl(
                  consumer: context.read<FirebaseConsumer>(),
                ),
              ),
              Provider<AdminRepository>(
                create: (context) => AdminRepositoryImpl(),
              ),
              BlocProvider<HomeCubit>(
                create: (context) => HomeCubit(
                  repository: context.read<HomeRepository>(),
                )..loadDashboard('1'),
              ),
              BlocProvider<AuthCubit>(
                create: (context) => AuthCubit(
                  repository: context.read<AuthRepository>(),
                ),
              ),
              BlocProvider<ProfileCubit>(
                create: (context) => ProfileCubit(
                  context.read<ProfileRepository>(),
                )..getProfile(),
              ),
              BlocProvider<SplashCubit>(
                create: (context) => SplashCubit(
                  repository: context.read<AuthRepository>(),
                ),
              ),
              BlocProvider<AdminCubit>(
                create: (context) => AdminCubit(
                  repository: context.read<AdminRepository>(),
                ),
              ),
              BlocProvider<ThemeCubit>(
                create: (context) => ThemeCubit(),
              ),
            ],
            child: BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, themeMode) {
                return MaterialApp.router(
                  // --- إعدادات اللغات بتاعتك ---
                  localizationsDelegates: context.localizationDelegates,
                  supportedLocales: context.supportedLocales,
                  locale: context.locale,

                  debugShowCheckedModeBanner: false,
                  title: AppStrings.appName,
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: themeMode,

                  // --- شاشة البداية ---
                  routerConfig: AppRouter.router,

                  builder: DevicePreview.appBuilder,
                );
              },
            ),
          ),
        );
      },
    );
  }
}
