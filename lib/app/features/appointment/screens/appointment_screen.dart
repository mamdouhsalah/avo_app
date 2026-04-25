import 'package:avo_app/app/core/constants/app_colors.dart';
import 'package:avo_app/app/core/constants/app_imgs.dart';
import 'package:avo_app/app/features/appointment/screens/canceled_appointments.dart';
import 'package:avo_app/app/features/appointment/screens/completed_appointments.dart';
import 'package:avo_app/app/features/appointment/screens/upcomming_appointments.dart';
import 'package:avo_app/app/features/appointment/screens/widgets/appointment_card.dart';
import 'package:avo_app/app/features/appointment/screens/widgets/cancel_appointment_card.dart';
import 'package:avo_app/app/features/appointment/screens/widgets/canceleld_succesfully_card.dart';
import 'package:avo_app/app/features/appointment/screens/widgets/payment_successfully_card.dart';
import 'package:avo_app/app/features/appointment/screens/widgets/selected_appointment_card.dart';
import 'package:flutter/material.dart';
import 'package:avo_app/app/features/appointment/data/models/appointment.dart';
import 'package:avo_app/app/features/appointment/data/mock_data.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppoiontmentScreen extends StatelessWidget {
  const AppoiontmentScreen({super.key});
  @override
  Widget build(BuildContext context) {
   final theme =  Theme.of(context);
   final colorScheme = theme.colorScheme;

    return DefaultTabController(
      length: 3,
      animationDuration: const Duration(milliseconds: 300),
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Appointments'),
          centerTitle: true,
          
          bottom: TabBar(

            dividerColor: Colors.transparent,
            indicatorWeight: 1.h,
              indicatorSize: TabBarIndicatorSize.label, 
              labelColor: colorScheme.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: colorScheme.primary,
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Completed'),
              Tab(text: 'Canceled'),
            ],
            labelPadding: EdgeInsets.symmetric( vertical: 0.h),
          ),
        ),
        body: SafeArea(
        child: TabBarView(
        children: [
          UpcomingAppointmentsScreen(),
          CompletedAppointmentsScreen(),
          CanceledAppointmentsScreen(),
        ],
      ),
    ),
        
      ),
    );
  }
}
