import 'package:avo_app/app/core/constants/app_imgs.dart';
import 'package:avo_app/app/core/constants/app_strings.dart';
import 'package:avo_app/app/core/models/onboard_model.dart';

List<SliderModel> getSliderData() {
  return [
    SliderModel(
      title: AppStrings.onBoardT1,
      description: AppStrings.onBoardD1,
      image: AppImgs.onboard1,
    ),
    SliderModel(
      title: AppStrings.onBoardT2,
      description: AppStrings.onBoardD2,
      image: AppImgs.onboard2,
    ),
    SliderModel(
      title: AppStrings.onBoardT3,
      description: AppStrings.onBoardD3,
      image: AppImgs.onboard3,
    ),
  ];
}
