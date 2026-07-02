import 'package:avo_app/app/core/models/appointment_card_model.dart';
import 'package:avo_app/app/features/doctor/view/widget/custom_appointmentcard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SpecificAppointmentDisplay extends StatelessWidget {

  final List<AppointmentCardModel> appointmentCards;
  const SpecificAppointmentDisplay({super.key, required this.appointmentCards});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0.h, horizontal: 16.w),
        child: ListView.separated(
          itemCount: appointmentCards.length,
          itemBuilder: (context, index) {
            return CustomAppointmentCard(
              appointmentCard: appointmentCards[index],
            );

          },
          separatorBuilder: (context, index) {
            return SizedBox(height: 10.h);
          },
        ),
      ),
    );
  }
}
