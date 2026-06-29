import 'package:avo_app/app/core/Language/locale_keys.g.dart';
import 'package:avo_app/app/core/models/appointment_card_model.dart';
import 'package:avo_app/app/features/appointment/screens/widgets/appointment_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UpcomingAppointmentsScreen extends StatelessWidget {
  List<AppointmentCardModel> appointmentCards;
  UpcomingAppointmentsScreen({super.key, required this.appointmentCards});

  @override
  Widget build(BuildContext context) {
    return
    appointmentCards.isEmpty?
    Center(
      child: Text(
        LocaleKeys.appointment_no_upcoming_to_display.tr(),
        style: TextStyle(color: Colors.grey , fontSize: 16.sp),
      ),
    )
    :
     ListView.builder(
      itemCount: appointmentCards.length,
      itemBuilder: (context, index) {
        return AppointmentCard(appointmentDoctor: appointmentCards[index]);
      },
    );
  }
}