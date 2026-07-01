import 'package:avo_app/app/core/models/appointment_card_model.dart';
import 'package:avo_app/app/core/shared/main_button.dart';
import 'package:avo_app/app/core/utils/date_utils.dart';
import 'package:avo_app/app/features/appointment/screens/widgets/info_card.dart';
import 'package:avo_app/app/features/appointment/screens/widgets/message.dart';
import 'package:avo_app/app/features/appointment/screens/widgets/priced_apoointment_card.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/Language/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DetailedAppointmenet extends StatelessWidget {
  AppointmentCardModel appointmentDoctor;
   DetailedAppointmenet({super.key , required this.appointmentDoctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.appointment_details_title.tr()),
      ),
      body: Center(
        child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // priced appointment card
                  PricedAppointmentCard(
                    appointmentDoctor: appointmentDoctor,
                  ),

                  SizedBox(height: 32.h),

                  Text(
                    LocaleKeys.appointment_schedule.tr(),
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 24.h),

                  // info cards for date and time
                  Row(
                    children: [
                      InfoCard(
                          title: LocaleKeys.general_date.tr(),
                          ///TODO: after modify date , uncomment this and make it a real date not just a day
                          value: ('${appointmentDoctor.appointment.date}')),

                      SizedBox(width: 16.w),
                      InfoCard(
                          title: LocaleKeys.general_time.tr(),
                          value: '${appointmentDoctor.appointment.startTime} - ${appointmentDoctor.appointment.startTime}'),
                    ],
                  ),
                  SizedBox(height:  24.5.h),

                  // message to doctor
                  const Message(),

                  SizedBox(height: 50.h),

                  MainButton(
                    text: LocaleKeys.general_continue_btn.tr(),
                    onPressed: () {
                      // do nothing for now
                    },
                    width: 343,
                    height: 48,
                  )
                ]
            )
        ),
      ),
    );
  }
}