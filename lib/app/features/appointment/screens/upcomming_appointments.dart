import 'package:avo_app/app/features/appointment/data/mock_data.dart';
import 'package:avo_app/app/features/appointment/screens/widgets/appointment_card.dart';
import 'package:flutter/material.dart';

class UpcomingAppointmentsScreen extends StatelessWidget {
  const UpcomingAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: upcomingAppointments.length,
      itemBuilder: (context, index) {
        return AppointmentCard(appointment: upcomingAppointments[index]);
      },
    );
  }
}