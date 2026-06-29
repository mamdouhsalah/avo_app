import 'package:avo_app/app/core/models/appointment_card_model.dart';
import 'package:avo_app/app/features/appointment/screens/widgets/appointment_card.dart';
import 'package:flutter/material.dart';

class CanceledAppointmentsScreen extends StatelessWidget {
  final List<AppointmentCardModel> canceledAppointments;
  const CanceledAppointmentsScreen({super.key , required this.canceledAppointments});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: canceledAppointments.length,
      itemBuilder: (context, index) {
        return AppointmentCard(appointmentDoctor: canceledAppointments[index]);
      },
    );
  }
}