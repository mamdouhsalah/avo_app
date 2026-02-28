import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:avo_app/features/onboard/logic/onboard_controller.dart';
import 'package:avo_app/core/constants/app_spacing.dart';
import 'package:avo_app/core/constants/app_text_style.dart';

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
          children: [
            /// PAGE VIEW
            Expanded(
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
                      horizontal: AppSpacing.hLg,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        /// Animated SVG
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: ScaleTransition(
                                scale: animation,
                                child: child,
                              ),
                            );
                          },
                          child: SvgPicture.asset(
                            slide.image,
                            key: ValueKey(slide.image),
                            height: 260.h,
                          ),
                        ),

                        SizedBox(height: AppSpacing.vxl),

                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: AppTextStyle.headline2,
                        ),

                        SizedBox(height: AppSpacing.vMd),

                        Text(
                          slide.description,
                          textAlign: TextAlign.center,
                          style: AppTextStyle.bodyMedium,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            /// DOT INDICATOR
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _controller.slides.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(
                    horizontal: AppSpacing.hVeryS,
                  ),
                  width: _controller.currentIndex == index ? 24.w : 8.w,
                  height: 8.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.circle),
                    color: _controller.currentIndex == index
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.2),
                  ),
                ),
              ),
            ),

            SizedBox(height: AppSpacing.vxl),

            /// BUTTONS
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.hLg,
                vertical: AppSpacing.vLg,
              ),
              child: Row(
                children: [
                  if (_controller.currentIndex != _controller.slides.length - 1)
                    TextButton(
                      onPressed: () {
                        _controller.skip();
                        setState(() {});
                      },
                      child: const Text("Skip"),
                    ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      if (_controller.currentIndex ==
                          _controller.slides.length - 1) {
                        // Navigator.pushReplacement(...);
                      } else {
                        _controller.nextPage();
                        setState(() {});
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.circle),
                      ),
                    ),
                    child: Text(
                      _controller.currentIndex == _controller.slides.length - 1
                          ? "Get Started"
                          : "Next",
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
