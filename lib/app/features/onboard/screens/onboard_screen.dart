import 'package:avo_app/app/core/constants/app_spacing.dart';
import 'package:avo_app/app/features/auth/screens/login_screen.dart';
import 'package:avo_app/app/features/onboard/logic/onboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  late final OnboardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = OnboardController();

    Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_controller.currentIndex < _controller.slides.length - 1) {
        _controller.nextPage();
        setState(() {});
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              flex: 1,
              child: PageView.builder(
                controller: _controller.pageController,
                itemCount: _controller.slides.length,
                onPageChanged: (index) {
                  setState(() {
                    _controller.onPageChanged(index);
                  });
                },
                itemBuilder: (context, index) {
                  final slide = _controller.slides[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.h16,
                      vertical: AppSpacing.v28,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        /// IMAGE
                        SvgPicture.asset(slide.image,
                            height: 343.h, width: 355.w, fit: BoxFit.contain),

                        SizedBox(height: AppSpacing.v24),

                        /// DOTS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _controller.slides.length,
                            (dotIndex) => Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.h8),
                              width: _controller.currentIndex == dotIndex
                                  ? 20.w
                                  : 10.w,
                              height: 10.h,
                              decoration: BoxDecoration(
                                color: _controller.currentIndex == dotIndex
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.secondary,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: AppSpacing.v24),

                        /// TITLE
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        SizedBox(height: AppSpacing.v16),

                        /// DESCRIPTION
                        Text(
                          slide.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  vertical: AppSpacing.v12, horizontal: AppSpacing.h12),
              child: Row(
                children: [
                  if (_controller.currentIndex != _controller.slides.length - 1)
                    TextButton(
                      onPressed: () {
                        _controller.skip();
                        setState(() {});
                      },
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  const Spacer(
                    flex: 1,
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_controller.currentIndex ==
                          _controller.slides.length - 1) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const LoginScreen(),
                          ),
                        );
                      } else {
                        _controller.nextPage();
                        setState(() {});
                      }
                    },
                    child: Container(
                      width: 50.w,
                      height: 50.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.navigate_next_outlined,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 40.sp,
                          // icon responsive to circle
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
