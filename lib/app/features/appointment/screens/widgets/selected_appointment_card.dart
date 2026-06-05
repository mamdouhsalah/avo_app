import 'package:avo_app/app/core/shared/main_button.dart';
import 'package:avo_app/app/core/utils/date_utils.dart';
import 'package:avo_app/app/core/utils/is_today.dart';
import 'package:avo_app/app/features/appointment/data/models/appointment.dart';
import 'package:avo_app/app/features/appointment/screens/widgets/call_message_chat_row.dart';
import 'package:flutter/material.dart';
import 'package:avo_app/app/core/constants/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SelectedAppointmentCard extends StatelessWidget {
  final Appointment appointment;

  const SelectedAppointmentCard({
    super.key,
    required this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.only(left: 24.0.w),
        child: SizedBox(
          height: 420.h,
          child: Container(
              width: 430.w,
              margin: EdgeInsets.only(right: 33.w),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                      color: colorScheme.onSurface.withValues(alpha: .1),
                      blurRadius: 5.r,
                      offset: Offset(0, 1),
                      spreadRadius: 1.r),
                ],
              ),
              child: Stack(children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // the top line
                    Center(
                      child: Container(
                        width: 134.w,
                        height: 5.h,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

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

                              SizedBox(height: 16.h),

                              // start and end time
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    color: colorScheme.onSurface,
                                    size: 18.sp,
                                  ),
                                  SizedBox(width: 10.w),
                                  Text(
                                    "${appointment.timeStart} - ${appointment.timeEnd}",
                                    style: TextStyle(
                                        color: colorScheme.onSurface,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w400),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 42.h),
                    // call , message and video icons
                    CallMessageChatRow(),

                    SizedBox(height: 24.h),

                    // Selected date
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected Date',
                          style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "${appointment.date.day} ${getMonthNameFromDate(date: appointment.date)} ",
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),

                    // Selected time
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected Time',
                          style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "${appointment.timeStart} - ${appointment.timeEnd}",
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),

                    /// button

                    MainButton(
                        text: "Cancel Appointment",
                        onPressed: () {},
                        width: 343,
                        height: 48)
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
