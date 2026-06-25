import 'package:avo_app/app/core/constants/app_imgs.dart';
import 'package:avo_app/app/core/models/onboard_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:avo_app/app/core/Language/locale_keys.g.dart';

List<SliderModel> getSliderData() {
  return [
    SliderModel(
      title: LocaleKeys.onboard_title_1.tr(),
      description: LocaleKeys.onboard_desc_1.tr(),
      image: AppImgs.onboard1,
    ),
    SliderModel(
      title: LocaleKeys.onboard_title_2.tr(),
      description: LocaleKeys.onboard_desc_2.tr(),
      image: AppImgs.onboard2,
    ),
    SliderModel(
      title: LocaleKeys.onboard_title_2.tr(),
      description: LocaleKeys.onboard_desc_3.tr(),
      image: AppImgs.onboard3,
    ),
  ];
}