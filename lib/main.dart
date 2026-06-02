import 'package:avo_app/app/core/services/remote/firebase_consumer_impl.dart';
import 'package:avo_app/my_app.dart';
import 'package:flutter/widgets.dart';
import 'package:easy_localization/easy_localization.dart';

import 'app/core/Language/codegen_loader.g.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // for firebase initialization
  final firebaseConsumer = FirebaseConsumerImpl();
  await firebaseConsumer.init();

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
      child: MyApp(firebaseConsumer: firebaseConsumer),
    ),
  );
}