import 'package:avo_app/app/core/Language/locale_keys.g.dart';
import 'package:avo_app/app/core/models/appointment_card_model.dart';
import 'package:avo_app/app/features/appointment/screens/widgets/appointment_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
class CanceledAppointmentsScreen extends StatelessWidget {
  final List<AppointmentCardModel> canceledAppointments;
  const CanceledAppointmentsScreen({super.key , required this.canceledAppointments});

  @override
  Widget build(BuildContext context) {
    return canceledAppointments.isEmpty?
    Center(
      child: Text(
        LocaleKeys.appointment_no_canceled_to_display.tr(),
        style: TextStyle(color: Colors.grey , fontSize: 16.sp),
      ),
    )
    : ListView.builder(
      itemCount: canceledAppointments.length,
      itemBuilder: (context, index) {
        return AppointmentCard(appointmentDoctor: canceledAppointments[index]);
      },
    );
  }
}