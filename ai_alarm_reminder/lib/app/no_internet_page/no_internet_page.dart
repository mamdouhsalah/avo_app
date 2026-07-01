import 'package:ai_alarm_reminder/app/core/utils/constance.dart';
import 'package:flutter/material.dart';
import 'package:gif_view/gif_view.dart';

class NoInternetPage extends StatefulWidget {
  const NoInternetPage({super.key});

  @override
  State<NoInternetPage> createState() => _NoInternetPageState();
}

class _NoInternetPageState extends State<NoInternetPage> {
  final GifController _controller = GifController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GifView.asset(
              controller: _controller,
              'assets/images/No connection.gif',
              height: 300,
              width: 300,
              frameRate: 30, // default is 15 FPS
            ),
            const Text(
              'Not Connected',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w100,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
