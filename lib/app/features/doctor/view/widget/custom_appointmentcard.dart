import 'package:avo_app/app/core/models/appointment_model.dart';
import 'package:avo_app/app/core/shared/custom_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math';

class CustomAppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final String? subtitle;
  final String? time;
  final String? room;

  const CustomAppointmentCard({
    super.key,
    required this.appointment,
    this.subtitle,
    this.time,
    this.room,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Color> flagColors = [
      Colors.deepPurple,
      Colors.orange,
      Colors.deepOrange,
      Colors.lightBlue,
      const Color(0xFF4ECDC4),
      Colors.indigo,
      Colors.pink,
    ];

    final Random random = Random(appointment.id.hashCode);
    final flagColor = flagColors[random.nextInt(flagColors.length)];

    final displayName = appointment.patientName ?? 'Patient';
    final displaySubtitle = subtitle ?? appointment.status;
    final displayTime = time ?? appointment.startTime;
    final displayDate = appointment.formattedDate;
    final displayRoom = room ?? "Room ${appointment.id.hashCode.abs() % 400 + 100}";

    // Status color
    Color statusColor;
    switch (appointment.status.toLowerCase()) {
      case 'confirmed':
        statusColor = Colors.green;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      case 'completed':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Container(
      padding: EdgeInsets.all(12.sp),
      width: double.infinity,
      height: 124.h,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: flagColor,
          width: 1.2.sp,
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
        children: [
          CustomAvatar(
            size: 52.r,
            radius: 50.r,
            borderColor: flagColor,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    displaySubtitle,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Text(
                      displayDate,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      displayTime,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
                Text(
                  displayRoom,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.edit),
                          title: const Text('Reschedule'),
                          onTap: () => Navigator.pop(context),
                        ),
                        ListTile(
                          leading: const Icon(Icons.cancel_outlined,
                              color: Colors.red),
                          title: const Text('Cancel Appointment',
                              style: TextStyle(color: Colors.red)),
                          onTap: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  );
                },
                icon: Icon(
                  Icons.more_vert,
                  color:
                      theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  size: 24.sp,
                ),
              ),
              Container(
                padding: EdgeInsets.all(9.sp),
                decoration: BoxDecoration(
                  color: flagColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.flag_rounded,
                  color: flagColor,
                  size: 22.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CustomGridAppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;

  const CustomGridAppointmentCard({
    super.key,
    required this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final displayName = appointment.patientName ?? 'Patient';
    final displaySubtitle = appointment.status;
    final displayTime = appointment.startTime;
    final displayRoom = "Room ${appointment.id.hashCode.abs() % 400 + 100}";

    final List<Color> flagColors = [
      Colors.deepPurple,
      Colors.orange,
      Colors.deepOrange,
      Colors.lightBlue,
      const Color(0xFF4ECDC4),
      Colors.indigo,
      Colors.pink,
    ];

    final Random random = Random(appointment.id.hashCode);
    final flagColor = flagColors[random.nextInt(flagColors.length)];

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: flagColor,
          width: 1.2.sp,
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
                  borderColor: flagColor,
                ),
              ),
              IconButton(
                padding: EdgeInsets.only(left: 24.w),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.edit),
                          title: const Text('Reschedule'),
                          onTap: () => Navigator.pop(context),
                        ),
                        ListTile(
                          leading: Icon(Icons.cancel_outlined,
                              color: theme.colorScheme.error),
                          title: Text('Cancel Appointment',
                              style: TextStyle(color: theme.colorScheme.error)),
                          onTap: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  );
                },
                icon: Icon(
                  Icons.more_vert,
                  color:
                      theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  size: 22.sp,
                ),
                constraints: const BoxConstraints(),
              )
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
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.75),
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
                color: flagColor,
                size: 32.sp,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
