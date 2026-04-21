import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart'; 
import 'Screens/profile_screen.dart';

void main() {
  runApp(
    
    DevicePreview(
      enabled: true, 
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      
      useInheritedMediaQuery: true, 
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ProfileScreen(), 
    );
  }
}