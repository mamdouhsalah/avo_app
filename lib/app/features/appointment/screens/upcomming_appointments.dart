import 'package:avo_app/app/core/models/appointment_card_model.dart';
import 'package:avo_app/app/features/appointment/screens/widgets/appointment_card.dart';
import 'package:flutter/material.dart';

class UpcomingAppointmentsScreen extends StatelessWidget {
  List<AppointmentCardModel> appointmentCards;
  UpcomingAppointmentsScreen({super.key, required this.appointmentCards});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: appointmentCards.length,
      itemBuilder: (context, index) {
        return AppointmentCard(appointmentDoctor: appointmentCards[index]);
      },
    );
  }
}