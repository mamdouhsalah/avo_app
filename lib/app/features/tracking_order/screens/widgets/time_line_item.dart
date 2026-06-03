import 'package:avo_app/app/features/tracking_order/data/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class TimelineItem extends StatelessWidget {
  final TrackingStep step;
  final bool isLast;
  final String svgPath;

  const TimelineItem(
      {super.key,
      required this.step,
      required this.isLast,
      required this.svgPath});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color circleColor;
    Color lineColor;
    Color textColor;

    switch (step.status) {
      case OrderStatus.completed:
        circleColor = theme.colorScheme.primary;
        lineColor = theme.colorScheme.primary;
        textColor = theme.colorScheme.onSurface;
        break;
      case OrderStatus.current:
        circleColor = theme.colorScheme.primary;
        lineColor = theme.colorScheme.outline;
        textColor = theme.colorScheme.onSurface;
        break;
      case OrderStatus.pending:
        circleColor = theme.disabledColor;
        lineColor = theme.disabledColor;
        textColor = theme.disabledColor;
        break;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// LEFT SIDE (ICON + LINE)
          Column(
            children: [
              /// Circle
              Container(
                width: 60.w,
                height: 60.h,
                decoration: BoxDecoration(
                  color: circleColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                    child: SvgPicture.asset(
                  svgPath,
                  width: 35.w,
                  height: 35.h,
                  fit: BoxFit.contain,
                )),
              ),

              /// Line
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.w,
                    height: 56.h,
                    color: lineColor,
                  ),
                ),
            ],
          ),

          SizedBox(width: 18.w),

          /// RIGHT SIDE (TEXT)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    step.date,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color
                          ?.withValues(alpha: 0.7),
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
