import 'package:avo_app/app/features/appointment/data/mock_data.dart';
import 'package:avo_app/app/features/cart/screens/widgets/cart_appointment.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.all(16.w),
          child: ListView.builder(
            itemCount: upcomingAppointments.length,
            itemBuilder:  (context, index) {
              return CartAppointment(appointment: upcomingAppointments[index]);
            },
        ), 
       ) 
      ),
    );
  }
}
