import 'package:avo_app/app/core/shared/main_button.dart';
import 'package:avo_app/app/features/appointment/screens/widgets/canceleld_succesfully_card.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/Language/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CancelAppointmentCard extends StatelessWidget {
  final String doctorName;
  final VoidCallback onYes;

  const CancelAppointmentCard({
    super.key,
    required this.doctorName,
    required this.onYes,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Material(
        color: colorScheme.surface,
        elevation: 10,
        shadowColor: colorScheme.onSurface.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
          ),
          width: 345.w,
          height: 267.h,
          child: Column(
            children: [
              // the top line
              Center(
                child: Padding(
                  padding: EdgeInsets.all(8.h),
                  child: Container(
                    width: 134.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              Text(
                LocaleKeys.appointment_cancel_appointment.tr(),
                style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface),
              ),

              SizedBox(height: 24.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Text(
                  LocaleKeys.appointment_cancel_confirm_msg.tr(namedArgs: {
                    'doctorName': doctorName,
                  }),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                ),
              ),

              SizedBox(height: 60.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MainButton(
                    text: LocaleKeys.general_yes.tr(),
                    onPressed: onYes,
                    width: 150.w,
                    height: 48.h,
                  ),
                  SizedBox(width: 21.w),
                  MainButton(
                    text: LocaleKeys.general_no.tr(),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    isNo: true,
                    width: 150.w,
                    height: 48.h,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
