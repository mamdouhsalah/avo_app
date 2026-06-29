import 'package:avo_app/app/core/Language/locale_keys.g.dart';
import 'package:avo_app/app/core/models/appointment_card_model.dart';
import 'package:avo_app/app/features/appointment/screens/widgets/completed_appointment_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CompletedAppointmentsScreen extends StatelessWidget {
  final List<AppointmentCardModel> completedAppointments;  
  const CompletedAppointmentsScreen({super.key , required this.completedAppointments});

  @override
  Widget build(BuildContext context) {
    return completedAppointments.isEmpty?
    Center(
      child: Text(
        LocaleKeys.appointment_no_completed_to_display.tr(),
        style: TextStyle(color: Colors.grey , fontSize: 16.sp),
      ),
    )
    :
    ListView.builder(
      itemCount: completedAppointments.length,
      itemBuilder: (context, index) {
        return CompletedAppointmentCard(appointmentDoctor: completedAppointments[index]);
      },
    );
  }
}