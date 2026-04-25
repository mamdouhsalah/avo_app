import 'package:avo_app/app/features/appointment/data/mock_data.dart';
import 'package:avo_app/app/features/appointment/screens/widgets/priced_apoointment_card.dart';
import 'package:flutter/material.dart';

class DetailedAppointmenet extends StatelessWidget {
  const DetailedAppointmenet({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
        title: Text('Appointment Details'),
      ),

      body: Center(
        child: Column(
          children: [
            // priced appointment card
              PricedAppointmentCard(appointment: upcomingAppointments[0],),
          ],
        ),
      ),
    );
  }

}