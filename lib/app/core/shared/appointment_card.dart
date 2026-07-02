import 'package:avo_app/app/core/constants/app_colors.dart';
import 'package:avo_app/app/core/models/appointment_card_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentCardModel appointmentCard;

  const AppointmentCard({
    super.key,
    required this.appointmentCard ,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 252.w,
      height: 158.h,
      // 🔥 استخدمنا EdgeInsetsDirectional عشان الـ end يقلب أوتوماتيك مع العربي
      margin: EdgeInsetsDirectional.only(end: 33.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 55.r,
                height: 55.r,
                padding: const EdgeInsets.all(0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.surface,
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: Icon(
                    Icons.person,
                    size: 30.r,
                    color: theme.colorScheme.surface,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointmentCard.doctor.name,
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w500,
                        fontSize: 16.sp,
                      ),
                    ),
                    Text(
                      appointmentCard.appointment.status,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.w400,
                        fontSize: 12.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Text(
                          appointmentCard.appointment.formattedDate,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.w400,
                            fontSize: 12.sp,
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Icon(Icons.calendar_today,
                            color: AppColors.lightOrangeOutLine, size: 16.sp),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                // 🔥 استخدمنا EdgeInsetsDirectional عشان الـ start يقلب أوتوماتيك مع العربي
                padding: EdgeInsetsDirectional.only(start: 30.w),
                onPressed: () {},
                icon: Icon(
                  Icons.more_vert,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 24.sp,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded,
                  color: Theme.of(context).colorScheme.onPrimary, size: 24.sp),
              SizedBox(width: 6.w),
              Text(
                appointmentCard. appointment.startTime,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w400,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(width: 25.w),
              Flexible(
                child: Row(
                  children: [
                    Icon(Icons.access_time,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 24.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        appointmentCard.appointment.endTime,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.w400,
                          fontSize: 12.sp,
                        ),
                        overflow: TextOverflow.visible,
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}