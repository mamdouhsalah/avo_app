import 'package:avo_app/app/core/constants/app_imgs.dart';
import 'package:easy_localization/easy_localization.dart'; // 🔥 الترجمة
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/Language/locale_keys.g.dart'; // 🔥 الـ LocaleKeys

class ScheduleHeader extends StatelessWidget {
  const ScheduleHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:  [
            Text(LocaleKeys.schedule_time_zone.tr(), // 🔥 تم التعديل إلى schedule
                style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
            SizedBox(height: 4.h),
            Text(LocaleKeys.schedule_est_time.tr(), // 🔥 تم التعديل إلى schedule
                style: TextStyle(fontWeight: FontWeight.w600 , color: colorScheme.onSurface)),
          ],
        ),
        const Spacer(),
        Container(
          width: 55.w,
          height: 55.h,
          decoration: BoxDecoration(
              border: Border.all(
                  width: 1.w
              ),
              borderRadius: BorderRadius.circular(200.r)
          ),
          child: CircleAvatar(
            radius: 22.r,
            backgroundImage: const AssetImage(
              AppImgs.doctor,
            ),
          ),
        )
      ],
    );
  }
}