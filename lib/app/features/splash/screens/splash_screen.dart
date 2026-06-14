import 'package:avo_app/app/core/constants/app_imgs.dart';
import 'package:avo_app/app/core/models/user_role.dart';
import 'package:avo_app/app/features/splash/logic/splash_cubit.dart';
import 'package:avo_app/app/features/splash/logic/splash_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:avo_app/app/core/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<SplashCubit>().checkToken();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
        listener: (context, state) {
          if (state is SplashSuccess) {
            if (state.role == UserRole.patient) {
              context.pushReplacement(AppRouter.home);
            } else if (state.role == UserRole.doctor) {
              context.pushReplacement(AppRouter.dashboard);
            } else if (state.role == UserRole.radiologySpecialist) {
              // TODO when radiologist exist
            } else if (state.role == UserRole.pharmacySpecialist) {
              // TODO when pharmacy exist
            } else if (state.role == UserRole.laboratorySpecialist) {
              // TODO when laboratory exist
            } else {
              // TODO when any other role
            }
          } else if (state is SplashFailure) {
            context.go(AppRouter.onboard);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Image.asset(
              AppImgs.logo,
              width: 200.w,
              fit: BoxFit.contain,
            ),
          ),
        ));
  }
}
