import 'package:avo_app/app/features/doctor/services/schedule_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:avo_app/app/core/models/appointment_model.dart';
import 'package:avo_app/app/features/doctor/services/schedule_controller.dart';

class WeekViewWidget extends StatelessWidget {
  final DateTime weekStart;
  final Function(DateTime) onDateSelected;

  const WeekViewWidget({
    super.key,
    required this.weekStart,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final weekAppointments =
        ScheduleController.getAppointmentsForWeek(weekStart);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ========== DAYS HEADER ==========
          _buildDaysHeader(),
          SizedBox(height: 16.h),

          // ========== TIMELINE ==========
          _buildTimeline(weekAppointments),
          SizedBox(height: 24.h),

          // ========== APPOINTMENTS LIST ==========
          _buildAppointmentsList(weekAppointments),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  // ========== DAYS HEADER ==========
  Widget _buildDaysHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          DateTime date = weekStart.add(Duration(days: index));
          String dayName = DateFormat('EEE').format(date);
          String dayNumber = date.day.toString();
          bool isToday = ScheduleController.isToday(date);

          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isToday ? const Color(0xFF00B8A9) : Colors.transparent,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                children: [
                  Text(
                    dayName,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 11.sp,
                      color: isToday ? Colors.white : Colors.black54,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    dayNumber,
                    style: TextStyle(
                      fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12.sp,
                      color: isToday ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ========== TIMELINE WITH EVENTS ==========
  Widget _buildTimeline(List<AppointmentModel> appointments) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            // Time rows with events
            ..._buildTimeRows(appointments),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTimeRows(List<AppointmentModel> allAppointments) {
    List<Widget> rows = [];

    for (int i = 0; i < 12; i++) {
      int hour = 8 + i;
      String timeLabel = '${hour.toString().padLeft(2, '0')}:00';

      // Get appointments for this hour
      List<AppointmentModel> appointmentsThisHour =
          allAppointments.where((apt) {
        return apt.timeRange.start.hour == hour;
      }).toList();

      rows.add(
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.withValues(alpha: 0.1),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time label
              SizedBox(
                width: 50.w,
                child: Text(
                  timeLabel,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: 12.w),

              // Appointments for this hour
              Expanded(
                child: appointmentsThisHour.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: appointmentsThisHour
                            .asMap()
                            .entries
                            .map((entry) => Padding(
                                  padding: EdgeInsets.only(bottom: 8.h),
                                  child: _buildEventCard(
                                    appointment: entry.value,
                                    colorIndex: entry.key,
                                  ),
                                ))
                            .toList(),
                      )
                    : SizedBox(height: 30.h),
              ),
            ],
          ),
        ),
      );
    }

    return rows;
  }

  // ========== EVENT CARD ==========
  Widget _buildEventCard({
    required AppointmentModel appointment,
    required int colorIndex,
  }) {
    final bgColor = ScheduleUtils.getEventColor(colorIndex);
    final borderColor = ScheduleUtils.getEventBorderColor(colorIndex);

    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.r),
        border:
            Border.all(color: borderColor.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time
          Text(
            '${ScheduleUtils.formatTime(appointment.timeRange.start)} - ${ScheduleUtils.formatTime(appointment.timeRange.end)}',
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),

          // Patient name
          Text(
            appointment.patient?.fullName ?? 'Unknown Patient',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),

          // Diagnosis
          Text(
            appointment.patient?.diagnosis ?? 'No Diagnosis',
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ========== APPOINTMENTS LIST ==========
  Widget _buildAppointmentsList(List<AppointmentModel> appointments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            'Week Appointments',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        if (appointments.isNotEmpty)
          ...appointments.take(6).map((apt) {
            int index = appointments.indexOf(apt);
            return _buildAppointmentItem(apt, index);
          })
        else
          Center(
            child: Text(
              'No appointments this week',
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey[500],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAppointmentItem(AppointmentModel apt, int index) {
    final color = ScheduleUtils.getEventColor(index);
    final borderColor = ScheduleUtils.getEventBorderColor(index);

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: borderColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 4.w,
              height: 50.h,
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    apt.patient?.fullName ?? 'Unknown Patient',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    apt.patient?.diagnosis ?? 'No Diagnosis',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 12.sp, color: Colors.grey),
                      SizedBox(width: 4.w),
                      Text(
                        DateFormat('MMM dd, yyyy').format(apt.date),
                        style:
                            TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
                      ),
                      SizedBox(width: 12.w),
                      Icon(Icons.access_time, size: 12.sp, color: Colors.grey),
                      SizedBox(width: 4.w),
                      Text(
                        ScheduleUtils.formatTime(apt.timeRange.start),
                        style:
                            TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
