import 'package:avo_app/app/core/models/appointment_card_model.dart';
import 'package:avo_app/app/features/appointment/screens/widgets/completed_appointment_card.dart';
import 'package:flutter/material.dart';

class CompletedAppointmentsScreen extends StatelessWidget {
  final List<AppointmentCardModel> completedAppointments;  
  const CompletedAppointmentsScreen({super.key , required this.completedAppointments});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: completedAppointments.length,
      itemBuilder: (context, index) {
        return CompletedAppointmentCard(appointmentDoctor: completedAppointments[index]);
      },
    );
  }
}