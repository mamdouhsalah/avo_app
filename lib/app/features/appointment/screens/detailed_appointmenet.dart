import 'package:avo_app/app/core/utils/date_utils.dart';
import 'package:avo_app/app/features/appointment/data/mock_data.dart';
import 'package:avo_app/app/features/appointment/screens/widgets/info_card.dart';
import 'package:avo_app/app/features/appointment/screens/widgets/priced_apoointment_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DetailedAppointmenet extends StatelessWidget {
  const DetailedAppointmenet({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment Details'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // priced appointment card
              PricedAppointmentCard(
                appointment: upcomingAppointments[0],
              ),

              SizedBox(height: 32.h),

              Text(
                'Schedule',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 24.h),

              // info cards for date and time
              Row(
                children: [
                  // date info card
                  InfoCard(
                      title: 'Date',
                      value: ('${upcomingAppointments[0].date.day} , ${getMonthNameFromDate(date: upcomingAppointments[0].date)}')),

                  SizedBox(width: 16.w),

                  // time info card
                  InfoCard(
                      title: 'Time',
                      value: '${upcomingAppointments[0].timeStart} - ${upcomingAppointments[0].timeEnd}'),
                ],
             )
            ]
           )
          ),
        ),
    );
  }
}
