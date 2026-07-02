import 'package:intl/intl.dart';
import 'package:avo_app/app/core/models/appointment_card_model.dart';
import 'package:avo_app/app/core/models/appointment_model.dart';
import 'package:avo_app/app/core/services/auth_service.dart';
import 'package:avo_app/app/core/services/local/hive_models.dart';
import 'package:avo_app/app/core/shared/main_button.dart';
import 'package:avo_app/app/core/utils/date_utils.dart';
import 'package:avo_app/app/core/utils/day_localizer.dart';
import 'package:avo_app/app/core/utils/is_today.dart';
import 'package:avo_app/app/features/appointment/logic/appointment_cubit.dart';
import 'package:avo_app/app/features/appointment/screens/widgets/cancel_appointment_card.dart';
import 'package:avo_app/app/features/appointment/screens/widgets/canceleld_succesfully_card.dart';
import 'package:avo_app/app/features/doctor/services/doctor_rating_cubit/doctor_rating_cubit.dart';
import 'package:avo_app/app/features/doctor/services/doctor_rating_cubit/doctor_rating_state.dart';
import 'package:avo_app/app/features/favorite/logic/favorite_cubit.dart';
import 'package:avo_app/app/features/favorite/logic/favorite_sate.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:avo_app/app/core/constants/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    final uid = context.read<AuthService>().currentUid;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final DateTime date = appointmentDoctor.appointment.date;
    
    bool isAppointmentToday = isToday(date: date);
    final formatted = DateFormat('d MMM').format(date);
    // Example: "8 Oct"

    return Padding(
      padding: EdgeInsetsDirectional.only(start: 24.w, top: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TODO: after modify date , uncomment this and make it a real date not just a day
          Text(
            isAppointmentToday
                ? LocaleKeys.general_today.tr():
                "${translateDay(appointmentDoctor.appointment.day)}  ${formatted} ",
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
                              child: appointmentDoctor
                                      .doctor.imageUrl.isNotEmpty
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

                                // get it from doctor rating, else get the updated rating
                                Row(
                                  children: [
                                    BlocBuilder<DoctorRatingCubit,
                                        DoctorRatingState>(
                                      builder: (context, state) {
                                        double rating =
                                            appointmentDoctor.doctor.rating;

                                        if (state is DoctorRatingSuccess) {
                                          rating = state.newDoctorRate;
                                        }

                                        return Text(
                                          rating.toStringAsFixed(2),
                                          style: TextStyle(
                                            color: colorScheme.onSurface,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        );
                                      },
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
                              : LocaleKeys.reminder_schedule.tr(),
                          onPressed: appointmentDoctor.appointment.status ==
                                  AppointmentStatus.confirmed
                              ? () {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    barrierColor: Colors.black54,
                                    builder: (_) {
                                      return CancelAppointmentCard(
                                        doctorName:
                                            appointmentDoctor.doctor.name,
                                        onYes: () {
                                          context
                                              .read<AppointmentCubit>()
                                              .cancelAppointment(
                                                appointmentDoctor
                                                    .appointment.id,
                                              );
                                          Navigator.pop(context);
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            barrierColor: Colors.black54,
                                            builder: (_) {
                                              return CancelSuccessfullyAppointmentCard(
                                                doctorName: appointmentDoctor
                                                    .doctor.name,
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                  );
                                }
                              : () {})
                    ],
                  ),
                ),

                /// Favorite icon => will be touchable in the future
                /// TODO: Speak with team about this
                /// add the doctor to favorite list or remove it from favorite list

                PositionedDirectional(
                  top: 8.h,
                  end: 41.w,
                  child: BlocBuilder<FavoriteCubit, FavoriteState>(
                    builder: (context, favoriteState) {
                      final isFav = context
                          .read<FavoriteCubit>()
                          .isFavorite(appointmentDoctor.doctor.id);

                      return IconButton(
                        onPressed: () {
                          context.read<FavoriteCubit>().toggleFavorite(
                                uid!,
                                appointmentDoctor.doctor.id,
                              );
                        },
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: Colors.red,
                          size: 24.sp,
                        ),
                      );
                    },
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
