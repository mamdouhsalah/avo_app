import 'package:ai_alarm_reminder/app/no_internet_page/no_internet_page.dart';
import 'package:ai_alarm_reminder/main.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';


class ConnectivityHandler extends StatefulWidget {
  final ConnectivityService connectivityService;
  final ConnectivityResult initialConnectivity;
  final Widget child;

  const ConnectivityHandler({
    super.key,
    required this.connectivityService,
    required this.initialConnectivity,
    required this.child,
  });

  @override
  _ConnectivityHandlerState createState() => _ConnectivityHandlerState();
}

class _ConnectivityHandlerState extends State<ConnectivityHandler> {
  late Stream<ConnectivityResult> _connectivityStream;
  ConnectivityResult? _connectivityStatus;

  @override
  void initState() {
    super.initState();
    _connectivityStream = widget.connectivityService.connectivityStream;
    _connectivityStatus = widget.initialConnectivity;
    _listenToConnectivity();
  }

  void _listenToConnectivity() {
    _connectivityStream.listen((connectivity) {
      setState(() {
        _connectivityStatus = connectivity;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main app content
        widget.child,

        if (_connectivityStatus == ConnectivityResult.none)
          const Positioned.fill(
            child: Material(
              color: Colors.white,
              child:  NoInternetPage(), 
            ),
          ),
      ],
    );
  }
}
