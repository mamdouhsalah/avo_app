import 'package:avo_app/app/core/constants/app_strings.dart';
import 'package:avo_app/app/core/routing/app_router.dart';
import 'package:avo_app/app/core/services/local/preferences_service.dart';
import 'package:avo_app/app/core/services/remote/firebase_consumer.dart';
import 'package:avo_app/app/core/shared/appointment_card.dart';
import 'package:avo_app/app/core/theme/theme_app.dart';
import 'package:avo_app/app/core/theme/theme_cubit.dart';
import 'package:avo_app/app/core/services/remote/sync_repository.dart';
import 'package:avo_app/app/features/doctor/data/doctor_repository.dart';
import 'package:avo_app/app/features/doctor/data/doctor_repository_impl.dart';
import 'package:avo_app/app/features/reminder/data/medication_log_repository.dart';
import 'package:avo_app/app/features/admin/data/admin_repository.dart';
import 'package:avo_app/app/features/admin/data/admin_repository_impl.dart';
import 'package:avo_app/app/features/admin/logic/admin_cubit.dart';
import 'package:avo_app/app/features/appointment/data/appointment_repo.dart';
import 'package:avo_app/app/features/appointment/data/appointment_repo_imp.dart';
import 'package:avo_app/app/features/appointment/logic/appointment_cubit.dart';
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
import 'package:avo_app/app/features/notification/data/repository/notification_repository.dart';
import 'package:avo_app/app/features/notification/data/repository/notification_repository_impl.dart';
import 'package:avo_app/app/features/notification/logic/app_notification_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  final FirebaseConsumer firebaseConsumer;
  final PreferencesService preferencesService;

  const MyApp(
      {super.key,
      required this.firebaseConsumer,
      required this.preferencesService});

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
              Provider<PreferencesService>.value(value: preferencesService),
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
                create: (context) =>
                    ThemeCubit(context.read<PreferencesService>()),
              ),
              Provider<NotificationRepository>(
                create: (context) => NotificationRepositoryImpl(),
              ),
              BlocProvider<AppNotificationCubit>(
                create: (context) => AppNotificationCubit(
                  repository: context.read<NotificationRepository>(),
                ),
              ),

             //doctor 
             Provider<DoctorRepository>(
              create: (context) => DoctorRepositoryImpl(
                consumer: context.read<FirebaseConsumer>(), 
              ),
            ),
              // appointment 
              Provider<AppointmentRepo>(
              create: (context) => AppointmentRepoImp(
                consumer: context.read<FirebaseConsumer>(),
                doctorRepository: context.read<DoctorRepository>(),
                patientRepository: context.read<ProfileRepository>(),
              ),
            ),

              BlocProvider<AppointmentCubit>(
                create: ((context) =>  AppointmentCubit(context.read<AppointmentRepo>())
              )),
            ],
            child: BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, themeMode) {
                final savedLanguage =
                    context.read<PreferencesService>().getLanguage();
                final locale = Locale(savedLanguage);

                final isLocalizationInitialized =
                    EasyLocalization.of(context) != null;

                return MaterialApp.router(
                  localizationsDelegates: isLocalizationInitialized
                      ? context.localizationDelegates
                      : null,
                  supportedLocales: isLocalizationInitialized
                      ? context.supportedLocales
                      : const [Locale('en')],
                  locale: isLocalizationInitialized ? context.locale : locale,
                  debugShowCheckedModeBanner: false,
                  title: AppStrings.appName,
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: themeMode,
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