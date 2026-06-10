import 'package:avo_app/app/core/constants/app_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class HeaderAuthSection extends StatelessWidget {
  final String title;
  final String subtitle;

  const HeaderAuthSection(
      {super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(children: [
      Center(
        child: SvgPicture.asset(
          AppSvg.logo,
          height: 80.h,
          colorFilter: ColorFilter.mode(colorScheme.primary, BlendMode.srcIn),
        ),
      ),
      Text(
        title,
        style: TextStyle(
          fontSize: 28.sp,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
      SizedBox(height: 8.h),
      Text(
        subtitle,
        style: TextStyle(
          fontSize: 16.sp,
          color: colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    ]);
  }
}
