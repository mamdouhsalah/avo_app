import 'package:avo_app/app/core/constants/app_svg.dart';
import 'package:avo_app/app/features/tracking_order/screens/widgets/time_line_item.dart';
import 'package:flutter/material.dart';
import 'package:avo_app/app/features/tracking_order/data/models/order_model.dart';

class TrackingTimeline extends StatelessWidget {
  final List<TrackingStep> steps;

  const TrackingTimeline({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    List svgs = [AppSvg.orderPlaced ,  AppSvg.shipped , AppSvg.delivered ];
    return Column(
      children: List.generate(steps.length, (index) {
        return TimelineItem(
          svgPath: svgs[index],
          step: steps[index],
          isLast: index == steps.length - 1,
        );
      }),
    );
  }
}
