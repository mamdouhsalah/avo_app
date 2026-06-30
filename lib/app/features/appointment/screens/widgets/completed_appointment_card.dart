import 'package:avo_app/app/core/models/appointment_card_model.dart';
import 'package:avo_app/app/core/models/appointment_model.dart';
import 'package:avo_app/app/core/shared/main_button.dart';
import 'package:avo_app/app/core/utils/date_utils.dart';
import 'package:avo_app/app/core/utils/day_localizer.dart';
import 'package:avo_app/app/core/utils/is_today.dart';
import 'package:avo_app/app/features/appointment/logic/appointment_cubit.dart';

import 'package:avo_app/app/features/appointment/screens/widgets/stars_rating.dart';
import 'package:avo_app/app/features/doctor/services/doctor_rating_cubit/doctor_rating_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:avo_app/app/core/constants/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/Language/locale_keys.g.dart';

class CompletedAppointmentCard extends StatefulWidget {
  final AppointmentCardModel appointmentDoctor;

  const CompletedAppointmentCard({
    super.key,
    required this.appointmentDoctor,
  });

  @override
  State<CompletedAppointmentCard> createState() =>
      _CompletedAppointmentCardState();
}

class _CompletedAppointmentCardState extends State<CompletedAppointmentCard> {
  late double selectedRating;

  @override
  void initState() {
    super.initState();
    selectedRating = widget.appointmentDoctor.appointment.patientRating ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isRated = context
            .read<AppointmentCubit>()
            .isRated(widget.appointmentDoctor.appointment.id) ??
        false;

    return Padding(
      padding: EdgeInsetsDirectional.only(start: 24.w, top: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // date on day for the appointment
          Text(
            "${translateDay(widget.appointmentDoctor.appointment.date)}",

            ///TODO: after modify date , uncomment this and make it a real date not just a day
            // isToday(date: appointmentDoctor.appointment.date)
            //     ? LocaleKeys.general_today.tr()
            //     : "${appointmentDoctor.appointment.date.day} ${getMonthNameFromDate(date: appointmentDoctor.appointment.date)}",
            style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 16.h),

          SizedBox(
            height: 240.h,
            child: Container(
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
                          child: widget
                                  .appointmentDoctor.doctor.imageUrl.isNotEmpty
                              ? Image.network(
                                  widget.appointmentDoctor.doctor.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/imgs/doctor/doctor1.png',
                                      fit: BoxFit.cover,
                                    );
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
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
                            Text(
                              widget.appointmentDoctor.doctor.name,
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                                fontSize: 16.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "(${widget.appointmentDoctor.doctor.specialty}${widget.appointmentDoctor.doctor.clinic})",
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w400,
                                fontSize: 12.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // rate and star
                      Row(
                        children: [
                          Text(
                            "${widget.appointmentDoctor.doctor.rating}",
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
                    ],
                  ),

                  // stars based on rating
                  RatingStars(
                    initialRating: selectedRating,
                    enabled: !isRated,
                    onRatingChanged: (rating) {
                      setState(() {
                        selectedRating = rating;
                      });
                    },
                  ),

                  SizedBox(height: 8.h),

                  // review your experience with the doctor
                  Center(
                    child: Text(
                      LocaleKeys.appointment_review_experience.tr(),
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  /// button // i think the main purpose is rating
                  MainButton(
                    text: isRated
                        ? LocaleKeys.appointment_rated.tr()
                        : LocaleKeys.appointment_submit_rating.tr(),
                    onPressed: isRated
                        ? null
                        : () async {
                            if (selectedRating == 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    LocaleKeys
                                        .appointment_select_rating_first
                                        .tr(),
                                  ),
                                ),
                              );
                              return;
                            }
                            await context
                                .read<DoctorRatingCubit>()
                                .rateDoctor(
                                  widget.appointmentDoctor.doctor.id,
                                  selectedRating,
                                );

                            await context
                                .read<AppointmentCubit>()
                                .submitRating(
                                  widget.appointmentDoctor.appointment.id,
                                  selectedRating,
                                );

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  LocaleKeys.appointment_rated_successfully
                                      .tr(),
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}