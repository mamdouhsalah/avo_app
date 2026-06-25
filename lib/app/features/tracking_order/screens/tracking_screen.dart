import 'package:avo_app/app/features/tracking_order/data/models/order_model.dart';
import 'package:avo_app/app/features/tracking_order/screens/widgets/order_card.dart';
import 'package:avo_app/app/features/tracking_order/screens/widgets/tracking_line_list.dart';
import 'package:easy_localization/easy_localization.dart'; // 🔥 الترجمة
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/Language/locale_keys.g.dart'; // 🔥 الـ LocaleKeys

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 💡 ملاحظة: التاريخ هنا hardcoded، يفضل تستخدم DateFormat في المستقبل
    final steps = [
      TrackingStep(
        title: LocaleKeys.tracking_order_placed.tr(), // 🔥 ترجمة
        date: "1 Dec, 2024 - 4:00pm",
        status: OrderStatus.completed,
      ),
      TrackingStep(
        title: LocaleKeys.tracking_shipped.tr(), // 🔥 ترجمة
        date: "3 Dec, 2024 - 4:00pm",
        status: OrderStatus.current,
      ),
      TrackingStep(
        title: LocaleKeys.tracking_delivered.tr(), // 🔥 ترجمة
        date: "3 Dec, 2024 - 4:00pm",
        status: OrderStatus.pending,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.tracking_title.tr()), // 🔥 ترجمة
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 💡 ملاحظة: تأكد إنك تمرر البيانات للـ OrderCard اللي عدلناه
            const OrderCard(
              orderId: "23528",
              trackingId: "IK123456789",
              deliveryDate: "3 Dec 2024",
            ),
            SizedBox(height: 62.h,),
            TrackingTimeline(steps: steps),
          ],
        ),
      ),
    );
  }
}