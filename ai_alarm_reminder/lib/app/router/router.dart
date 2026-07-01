import 'package:ai_alarm_reminder/app/features/home/view/home.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


final GoRouter router = GoRouter(
  // routerNeglect: true,
  initialLocation: '/',

  routes: [
    GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          // Initialize the BaseIndexCubit if needed

          return const HomePage();
        },
        routes: const [
          // GoRoute(
          //   path: 'SignUp',
          //   builder: (BuildContext context, GoRouterState state) {
          //     return const SignUpPage();
          //   },
          // ),
        ])
  ],
);
