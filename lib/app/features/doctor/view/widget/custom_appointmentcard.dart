import 'package:avo_app/app/core/models/appointment_card_model.dart';
import 'package:avo_app/app/core/models/appointment_model.dart';
import 'package:avo_app/app/core/routing/app_router.dart';
import 'package:avo_app/app/core/shared/custom_avatar.dart';
import 'package:avo_app/app/features/doctor/helpers/status_hlper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:avo_app/app/core/models/appointment_action_arg.dart';
import 'package:avo_app/app/core/Language/locale_keys.g.dart';

class CustomAppointmentCard extends StatelessWidget {
  final AppointmentCardModel appointmentCard;
  final String? subtitle;
  final String? time;
  final String? room;

  const CustomAppointmentCard({
    super.key,
    required this.appointmentCard,
    this.subtitle,
    this.time,
    this.room,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = AppointmentStatusHelper.getColor(
      appointmentCard.appointment.status,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () {
          context.push(AppRouter.appointmentAction,
              extra: AppointmentActionArgs(
                patient: appointmentCard.patient!,
                appointmentId: appointmentCard.appointment.id,
                appointmentStatus: appointmentCard.appointment.status,
              ));
        },
        child: Container(
          padding: EdgeInsets.all(12.sp),
          width: double.infinity,
          height: 130.h,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: statusColor,
              width: .5.sp,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomAvatar(
                size: 52.r,
                radius: 50.r,
                borderColor: statusColor,
                imageUrl: appointmentCard.patient!.image,
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      appointmentCard.patient!.fullName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                        color: theme.textTheme.titleLarge?.color,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle ?? appointmentCard.appointment.status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Column(
                      children: [
                        Text(
                          time ?? appointmentCard.appointment.startTime,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                            color: theme.textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.9),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          room ?? "Room",
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                              color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.flag_rounded,
                color: statusColor,
                size: 26.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomGridAppointmentCard extends StatelessWidget {
  final AppointmentCardModel appointmentCard;

  const CustomGridAppointmentCard({
    super.key,
    required this.appointmentCard,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = AppointmentStatusHelper.getColor(
      appointmentCard.appointment.status,
    );
    final displayName = appointmentCard.patient!.fullName;
    final displaySubtitle = appointmentCard.appointment.status;
    final displayTime = appointmentCard.appointment.startTime;
    final displayRoom = "room";

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          context.push(AppRouter.appointmentAction,
              extra: AppointmentActionArgs(
                patient: appointmentCard.patient!,
                appointmentId: appointmentCard.appointment.id,
                appointmentStatus: appointmentCard.appointment.status,
              ));
        },
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: statusColor,
              width: .5.sp,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: CustomAvatar(
                      size: 58.r,
                      radius: 50.r,
                      borderColor: statusColor,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 14.h),

              // Name
              Text(
                displayName,
                style: TextStyle(
                  fontSize: 16.5.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleLarge?.color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: 4.h),

              Text(
                displaySubtitle,
                style: TextStyle(
                  fontSize: 13.5.sp,
                  color: theme.textTheme.bodyMedium?.color
                      ?.withValues(alpha: 0.75),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const Spacer(),

              // Time & Room
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        displayTime,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.9),
                        ),
                      ),
                      Text(
                        displayRoom,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: theme.textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Icon(
                    Icons.flag_rounded,
                    color: statusColor,
                    size: 32.sp,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
