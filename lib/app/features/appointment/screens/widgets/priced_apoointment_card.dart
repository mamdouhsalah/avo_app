import 'package:avo_app/app/core/constants/app_colors.dart';
import 'package:avo_app/app/core/models/appointment_card_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PricedAppointmentCard extends StatelessWidget {
  final AppointmentCardModel appointmentDoctor;
  const PricedAppointmentCard({super.key , required this.appointmentDoctor});

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
              margin: EdgeInsetsDirectional.only(end: 33.w),
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
                      child: appointmentDoctor.doctor.imageUrl.isNotEmpty
                          ? Image.network(
                              appointmentDoctor.doctor.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/imgs/doctor/doctor1.png',
                                  fit: BoxFit.cover,
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                );
                              },
                            )
                          : Image.asset(
                              'assets/imgs/doctor/doctor1.png',
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
                                appointmentDoctor.doctor.name,
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16.sp,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),

                              Text(
                                "(${appointmentDoctor.doctor.specialty}  ${appointmentDoctor.doctor.clinic})",
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
                                "\$${appointmentDoctor.doctor.price.toStringAsFixed(2)}",
                                
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

                PositionedDirectional(
                  top: 0,
                  end: 0,
                  child: Row(
                    children: [
                      /// rating
                      Text(
                        "${appointmentDoctor.doctor.rating}",
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