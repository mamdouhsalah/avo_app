import 'package:avo_app/app/core/services/local/preferences_service.dart';
import 'package:avo_app/app/core/services/remote/firebase_consumer_impl.dart';
import 'package:avo_app/my_app.dart';
import 'package:flutter/widgets.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'app/core/Language/codegen_loader.g.dart';

import 'package:avo_app/app/core/services/local/hive_service.dart';
import 'package:avo_app/app/core/services/local/points_service.dart';
import 'package:avo_app/app/core/services/local/health_metrics_service.dart';
import 'package:avo_app/app/core/services/local/hive_medical_analysis_service.dart';
import 'package:avo_app/app/features/notification/services/notification_service.dart';
import 'package:avo_app/app/features/notification/services/fcm_service.dart';
import 'package:avo_app/app/core/services/remote/presence_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firebaseConsumer = FirebaseConsumerImpl();
  await firebaseConsumer.init();

  await HiveService.init();
  await PointsService.init();
  await HealthMetricsService.init();
  await MedicalAnalysisService().init();
  await NotificationService.init();
  await FCMService.initialize();
  PresenceService.initialize();

  final preferencesService = PreferencesService();
  final savedLanguage = preferencesService.getLanguage();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      path: 'assets/translations/',
      useOnlyLangCode: true,
      useFallbackTranslations: true,
      assetLoader: CodegenLoader(),
      fallbackLocale: const Locale('en'),
      startLocale: Locale(savedLanguage),
      child: MyApp(
          firebaseConsumer: firebaseConsumer,
          preferencesService: preferencesService),
    ),
  );
}
