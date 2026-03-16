import 'package:avo_app/app/core/models/onboard_model.dart';
import 'package:avo_app/app/features/onboard/data/onboard_data.dart';
import 'package:flutter/material.dart';

class OnboardController {
  final PageController pageController = PageController();
  late List<SliderModel> slides;
  int currentIndex = 0;

  OnboardController() {
    slides = getSliderData();
  }

  void onPageChanged(int index) {
    currentIndex = index;
  }

  void nextPage() {
    if (currentIndex < slides.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void skip() {
    pageController.jumpToPage(slides.length - 1);
  }

  void dispose() {
    pageController.dispose();
  }
}
