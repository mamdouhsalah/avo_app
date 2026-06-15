import 'package:avo_app/app/core/constants/app_colors.dart';
import 'package:avo_app/app/features/appointment/data/models/appointment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PricedAppointmentCard extends StatelessWidget {
  final Appointment appointment;
  const PricedAppointmentCard({super.key , required this.appointment});

   @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: 16.h),
        child: SizedBox(
          height: 106.h,
          child: Container(
              width: 343.w,
              margin: EdgeInsets.only(right: 33.w),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: colorScheme.primary, width: 2),
                
              ),
              child: Stack(children: [
                Column(
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
                    // will be a static text temporarily 
                    Text(
                      "Hourly Rated : \$120",
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

                  ],
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Row(
                    children: [
                      /// rating
                      Text(
                        "${appointment.rating}",
                        style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400),
                      ),

                      SizedBox(width: 10.w),

                      Icon(
                        Icons.star,
                        color: AppColors.lightOrangeOutLine,
                        size: 18.sp,
                      ),
                    ],
                  ),
                )
              ])),
        ),
      ),
    );
  }
}