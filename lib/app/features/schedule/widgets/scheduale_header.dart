import 'package:avo_app/app/core/constants/app_imgs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScheduleHeader extends StatelessWidget {
  const ScheduleHeader({super.key});

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final ColorScheme = theme.colorScheme;

    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:  [
            Text("Time Zone",
                style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
            SizedBox(height: 4.h),
            Text("EST time...", style: TextStyle(fontWeight: FontWeight.w600 , color: ColorScheme.onSurface)),
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
            backgroundImage: AssetImage(
              AppImgs.doctor,
            ),
          ),
        )
      ],
    );
  }
}
