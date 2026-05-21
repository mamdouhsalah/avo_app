import 'package:avo_app/app/features/tracking_order/data/models/order_model.dart';
import 'package:avo_app/app/features/tracking_order/screens/widgets/order_card.dart';
import 'package:avo_app/app/features/tracking_order/screens/widgets/tracking_line_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = [
      TrackingStep(
        title: "Order Placed",
        date: "1 Dec, 2024 - 4:00pm",
        status: OrderStatus.completed,
      ),
      TrackingStep(
        title: "Shipped",
        date: "3 Dec, 2024 - 4:00pm",
        status: OrderStatus.current,
      ),
      TrackingStep(
        title: "Delivered",
        date: "3 Dec, 2024 - 4:00pm",
        status: OrderStatus.pending,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tracking Order"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const OrderCard(),
            SizedBox(height: 62.h,),
            TrackingTimeline(steps: steps),
          ],
        ),
      ),
    );
  }
}