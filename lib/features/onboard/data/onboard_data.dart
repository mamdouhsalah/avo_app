import 'package:avo_app/core/constants/app_imgs.dart';
import 'package:avo_app/core/models/onboard_model.dart';

List<SliderModel> getSliderData() {
  return [
    SliderModel(
      title: "Welcome to AVO",
      description:
          "Your health companion for doctors, pharmacies and radiology centers.",
      image: AppImgs.onboard1,
    ),
    SliderModel(
      title: "Book Easily",
      description: "Schedule appointments with top doctors in seconds.",
      image: AppImgs.onboard2,
    ),
    SliderModel(
      title: "All Medical Services",
      description:
          "Access pharmacies, labs and radiology centers in one place.",
      image: AppImgs.onboard3,
    ),
  ];
}
