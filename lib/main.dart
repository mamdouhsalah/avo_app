import 'package:avo_app/my_app.dart';
import 'package:flutter/widgets.dart';

void main() {
  // ScreenUtilInit is always first render ancestor
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}