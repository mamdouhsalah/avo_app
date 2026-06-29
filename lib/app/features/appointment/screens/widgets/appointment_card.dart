import 'package:avo_app/app/core/models/appointment_card_model.dart';
import 'package:avo_app/app/core/models/appointment_model.dart';
import 'package:avo_app/app/core/services/local/hive_models.dart';
import 'package:avo_app/app/core/shared/main_button.dart';
import 'package:avo_app/app/core/utils/date_utils.dart';
import 'package:avo_app/app/core/utils/day_localizer.dart';
import 'package:avo_app/app/core/utils/is_today.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:avo_app/app/core/constants/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/Language/locale_keys.g.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentCardModel appointmentDoctor;

  const AppointmentCard({
    super.key,
    required this.appointmentDoctor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsetsDirectional.only(start: 24.w, top: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TODO: after modify date , uncomment this and make it a real date not just a day
          Text(
            // isToday(date: appointmentDoctor.appointment.date)
            //     ? LocaleKeys.general_today.tr()
            //     :
            "${translateDay(appointmentDoctor.appointment.date)}",
            style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 16.h),

          SizedBox(
            height: 185.h,
            child: Stack(
              children: [
                Container(
                  width: 343.w,
                  margin: EdgeInsetsDirectional.only(end: 33.w),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: colorScheme.primary,
                      width: 1.w,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// ================= TOP =================
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
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Image.asset(
                                          'assets/imgs/doctor/doctor1.png',
                                          fit: BoxFit.cover,
                                        );
                                      },
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return const Center(
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
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
                                /// leave space for the heart button at top right
                                SizedBox(width: 24.w),

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
                                  "(${appointmentDoctor.doctor.specialty}${appointmentDoctor.doctor.clinic})",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12.sp,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                SizedBox(height: 16.h),

                                Row(
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

                                    SizedBox(width: 10.w),

                                    Icon(
                                      Icons.access_time,
                                      color: colorScheme.onSurface,
                                      size: 18.sp,
                                    ),

                                    SizedBox(width: 10.w),

                                    Text(
                                      "${appointmentDoctor.appointment.startTime} - ${appointmentDoctor.appointment.endTime}",
                                      style: TextStyle(
                                          color: colorScheme.onSurface,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w400),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20.h),

                      /// button
                      MainButton(
                          text: appointmentDoctor.appointment.status ==
                                  AppointmentStatus.confirmed
                              ? LocaleKeys.appointment_cancel_appointment.tr()
                              : LocaleKeys.appointment_reschedule.tr(),
                          onPressed: () {})
                    ],
                  ),
                ),

                /// Favorite icon => will be touchable in the future
                /// TODO: Speak with team about this
                /// add the doctor to favorite list or remove it from favorite list
                PositionedDirectional(
                  top: 8.h,
                  end: 41.w, // accounts for the end margin of the container
                  child: IconButton(
                    onPressed: () {
                      // set doctor as favorite or remove it from favorite list
                    },
                    icon: Icon(
                      appointmentDoctor.doctor.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: AppColors.lightOrangeOutLine,
                      size: 24.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}