import 'package:avo_app/app/core/constants/app_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          width: 2.w,
          color: theme.colorScheme.primary
        ),
        
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// LEFT TEXT
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Order #23528",
                  style: theme.textTheme.titleMedium),
             SizedBox(height: 4),
              Text("Tracking ID: IK123456789",
                  style: theme.textTheme.bodySmall),
             SizedBox(height: 4),
              Text("Expected Delivery: 3 Dec 2024",
                  style: theme.textTheme.bodySmall),
            ],
          ),

          /// RIGHT ICON
          SvgPicture.asset(
            AppSvg.shipped,
            height: 50.h,
            width: 50.w,
          ),
        ],
      ),
    );
  }
}