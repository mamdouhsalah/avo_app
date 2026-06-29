import 'package:avo_app/app/core/shared/main_button.dart';
import 'package:avo_app/app/features/appointment/models/appointment.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/Language/locale_keys.g.dart';

class CartAppointment extends StatelessWidget {
  final Appointment appointment;
  const CartAppointment({super.key , required this.appointment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: 16.h),
        child: SizedBox(
          height: 170.h,
          child: Container(
              width: 343.w,
              margin: EdgeInsetsDirectional.only(end: 33.w),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: colorScheme.primary, width: 2),

              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Image
                      Container(
                        width: 55.r,
                        height: 55.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            appointment.doctorPictureUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      SizedBox(width: 16.w),

                      /// Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appointment.doctorName,
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                                fontSize: 16.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            Text(
                              "(${appointment.specialty} | ${appointment.clinic})",
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w400,
                                fontSize: 12.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            // hourly rate
                            Text(
                              'appointment.hourly_rate'.tr(namedArgs: {
                                'price': '\$120'
                              }),
                              style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 34.h,),

                  // make payment button
                  MainButton(
                    text: LocaleKeys.cart_make_payment.tr(),
                    onPressed: (){},
                    width: 311.w,
                    height: 32.h,
                  )
                ],
              )
          ),
        ),
      ),
    );
  }
}