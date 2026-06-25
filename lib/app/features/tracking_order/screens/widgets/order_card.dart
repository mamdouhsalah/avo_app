import 'dart:ui' as ui;

import 'package:avo_app/app/core/constants/app_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/Language/locale_keys.g.dart';


class OrderCard extends StatelessWidget {
  final String orderId;
  final String trackingId;
  final String deliveryDate;

  const OrderCard({
    super.key,
    required this.orderId,
    required this.trackingId,
    required this.deliveryDate,
  });

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
          color: theme.colorScheme.primary,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// LEFT TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.order_card_order_id.tr(namedArgs: {'id': orderId}),
                  style: theme.textTheme.titleMedium,
                ),
                SizedBox(height: 4.h),
                Text(
                  LocaleKeys.order_card_tracking_id.tr(namedArgs: {'id': trackingId}),
                  style: theme.textTheme.bodySmall,
                  textDirection: ui.TextDirection.ltr,
                ),
                SizedBox(height: 4.h),
                Text(
                  LocaleKeys.order_card_expected_delivery.tr(namedArgs: {'date': deliveryDate}),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
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