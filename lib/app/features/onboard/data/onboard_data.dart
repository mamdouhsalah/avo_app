import 'package:avo_app/app/core/constants/app_imgs.dart';
import 'package:avo_app/app/core/models/onboard_model.dart';

List<SliderModel> getSliderData() {
  return [
    SliderModel(
      title: 'Welcome to AVO',
      description: 'Your Health Companion',
      image: AppImgs.onboard1,
    ),
    SliderModel(
      description: 'Schedule appointments with top doctors in seconds.',
      title: 'All Medical Services',
      image: AppImgs.onboard2,
    ),
    SliderModel(
      title: 'All Medical Services',
      description:
          'Access pharmacies, labs and radiology centers in one place.',
      image: AppImgs.onboard3,
    ),
  ];
}
