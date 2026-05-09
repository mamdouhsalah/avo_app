import 'package:avo_app/my_app.dart';
import 'package:flutter/widgets.dart';
import 'package:easy_localization/easy_localization.dart';

import 'app/core/Language/codegen_loader.g.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

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
      child: const MyApp(),
    ),
  );
}
