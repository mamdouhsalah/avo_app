import 'package:ai_alarm_reminder/app/core/services/connectivity_handler.dart';
import 'package:ai_alarm_reminder/app/core/services/health_metrics_service.dart';
import 'package:ai_alarm_reminder/app/core/services/points_service.dart';
import 'package:ai_alarm_reminder/app/core/services/hive_service.dart';
import 'package:ai_alarm_reminder/app/core/services/notification_service.dart';
import 'package:ai_alarm_reminder/app/core/services/service_models/hive_medical_analysis_service.dart';
import 'package:ai_alarm_reminder/app/core/utils/constance.dart';
// import 'package:ai_alarm_reminder/app/features/add_reminder_page/hive_models/drug.dart';
import 'package:ai_alarm_reminder/app/features/home/view/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

@pragma("vm:entry-point") // VERY important for background execution
Future<void> myNotificationActionHandler(ReceivedAction receivedAction) async {
  // Handle background action here
  print(
      'ðŸ”” Notification action (background): ${receivedAction.buttonKeyPressed}');
  NotificationService.handleNotificationAction(receivedAction);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await HiveService.init();
  await NotificationService.init();
  await initializeDateFormatting('ar', null);
  await initializeDateFormatting('ar_SA', null);
  Hive.registerAdapter(MedicalAnalysisAdapter());
  Hive.registerAdapter(AnalysisStateAdapter());
  MedicalAnalysisService medicalAnalysisService = MedicalAnalysisService();
  await medicalAnalysisService.init();
  await HealthMetricsService.init();
  await PointsService.init();
  _requestNotificationPermission();

  runApp(MyApp());
}

void _requestNotificationPermission() async {
  await AwesomeNotifications().requestPermissionToSendNotifications(
    channelKey: 'med_channel',
    permissions: [
      NotificationPermission.Alert,
      NotificationPermission.Sound,
      NotificationPermission.Vibration,
      NotificationPermission.FullScreenIntent, // Request full-screen permission
    ],
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final ConnectivityService connectivityService = ConnectivityService();

  // This widcoget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return Directionality(
          textDirection:
              TextDirection.rtl, // or rtl depending on your app's language
          child: ConnectivityHandler(
            connectivityService: connectivityService,
            initialConnectivity: ConnectivityResult.mobile,
            child: MaterialApp(
          locale: Locale('ar'),
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: themeData(),
          supportedLocales: const [
            Locale('ar'), // Arabic
          ],
          home: const BaseScreen(),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate
          ],
        ),
      ),
    );
      },
    );
  }
}

class ConnectivityService {
  ConnectivityService();

  final Connectivity _connectivity = Connectivity();
  Stream<ConnectivityResult> get connectivityStream =>
      _connectivity.onConnectivityChanged
          .asyncExpand((results) => Stream.fromIterable(results));

  Future<ConnectivityResult> checkInitialConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    return results.isNotEmpty ? results.first : ConnectivityResult.none;
  }
}

// import 'package:ai_alarm_reminder/test.dart';
