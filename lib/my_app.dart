import 'package:avo_app/app/core/constants/app_strings.dart';
import 'package:avo_app/app/core/routing/app_router.dart';
import 'package:avo_app/app/core/services/remote/firebase_consumer.dart';
import 'package:avo_app/app/core/theme/theme_app.dart';
import 'package:avo_app/app/core/theme/theme_cubit.dart';
import 'package:avo_app/app/core/services/remote/sync_repository.dart';
import 'package:avo_app/app/features/reminder/data/medication_log_repository.dart';
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
import 'package:avo_app/app/features/reminder/logic/reminder_cubit.dart';
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
      builder: (screenUtilContext, child) {
        return DevicePreview(
          enabled: false,
          builder: (devicePreviewContext) => MultiProvider(
            providers: [
              Provider<FirebaseConsumer>.value(value: firebaseConsumer),
              Provider<HomeRepository>(
                create: (providerContext) => HomeRepositoryImpl(
                  consumer: providerContext.read<FirebaseConsumer>(),
                ),
              ),
              Provider<AuthRepository>(
                create: (providerContext) => AuthRepositoryImpl(
                  consumer: providerContext.read<FirebaseConsumer>(),
                ),
              ),
              Provider<ProfileRepository>(
                create: (providerContext) => ProfileRepositoryImpl(
                  consumer: providerContext.read<FirebaseConsumer>(),
                ),
              ),
              Provider<AdminRepository>(
                create: (context) => AdminRepositoryImpl(),
              ),
              Provider<SyncRepository>(
                create: (providerContext) => SyncRepository(
                  firebaseConsumer: providerContext.read<FirebaseConsumer>(),
                ),
              ),
              Provider<LogRepository>(
                create: (providerContext) => LogRepository(
                  firebaseConsumer: providerContext.read<FirebaseConsumer>(),
                ),
              ),
              BlocProvider<HomeCubit>(
                create: (providerContext) => HomeCubit(
                  repository: providerContext.read<HomeRepository>(),
                )..loadDashboard('1'),
              ),
              BlocProvider<ReminderCubit>(
                create: (providerContext) => ReminderCubit(
                  firebaseConsumer: providerContext.read<FirebaseConsumer>(),
                  logRepository: providerContext.read<LogRepository>(),
                )..loadTodaysMedications(),
              ),
              BlocProvider<AuthCubit>(
                create: (providerContext) => AuthCubit(
                  repository: providerContext.read<AuthRepository>(),
                  syncRepository: providerContext.read<SyncRepository>(),
                ),
              ),
              BlocProvider<ProfileCubit>(
                create: (providerContext) => ProfileCubit(
                  providerContext.read<ProfileRepository>(),
                )..getProfile(),
              ),
              BlocProvider<SplashCubit>(
                create: (providerContext) => SplashCubit(
                  repository: providerContext.read<AuthRepository>(),
                  syncRepository: providerContext.read<SyncRepository>(),
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
            // 🔥 دمجنا الـ BlocBuilder للـ Theme مع حماية الـ EasyLocalization
            child: BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, themeMode) {
                final isLocalizationInitialized = EasyLocalization.of(context) != null;
                
                return MaterialApp.router(
                  // --- إعدادات اللغات بتاعتك ---
                  localizationsDelegates: isLocalizationInitialized
                      ? context.localizationDelegates
                      : null,
                  supportedLocales: isLocalizationInitialized
                      ? context.supportedLocales
                      : const [Locale('en')],
                  locale: isLocalizationInitialized
                      ? context.locale
                      : const Locale('en'),

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