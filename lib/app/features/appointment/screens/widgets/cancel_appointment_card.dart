import 'package:avo_app/app/core/shared/main_button.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/Language/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CancelAppointmentCard extends StatelessWidget {
  final String doctorName;
  const CancelAppointmentCard({super.key, required this.doctorName});

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
          width: 375.w,
          height: 267.h,
          child: Column(
            children: [
              // the top line
              Center(
                child: Container(
                  width: 134.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface,
                    borderRadius: BorderRadius.circular(10.r),
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

              Text(
                'appointment.cancel_confirm_msg'.tr(namedArgs: {
                  'doctorName': doctorName,
                }),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.sp, color: Colors.grey),
              ),

              SizedBox(height: 60.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MainButton(
                    text: LocaleKeys.general_yes.tr(),
                    onPressed: () {},
                    width: 161.w,
                    height: 48.h,
                  ),
                  SizedBox(width: 21.w),
                  MainButton(
                    text: LocaleKeys.general_no.tr(),
                    onPressed: () {},
                    isNo: true,
                    width: 161.w,
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