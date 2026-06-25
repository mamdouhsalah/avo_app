import 'package:avo_app/app/features/appointment/data/mock_data.dart';
import 'package:avo_app/app/features/cart/screens/widgets/cart_appointment.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/Language/locale_keys.g.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.cart_title.tr()),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: ListView.builder(
            itemCount: upcomingAppointments.length,
            itemBuilder: (context, index) {
              return CartAppointment(appointment: upcomingAppointments[index]);
            },
          ),
        ),
      ),
    );
  }
}