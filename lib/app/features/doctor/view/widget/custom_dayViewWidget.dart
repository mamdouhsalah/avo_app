import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:avo_app/app/core/models/appointment_model.dart';
import 'package:avo_app/app/features/doctor/services/schedule_controller.dart';
import 'package:avo_app/app/features/doctor/services/schedule_utils.dart';

class DayViewWidget extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;

  const DayViewWidget({
    Key? key,
    required this.selectedDate,
    required this.onDateChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dayAppointments =
        ScheduleController.getAppointmentsForDate(selectedDate);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ========== DATE NAVIGATION ==========
          _buildDateNavigation(context),
          SizedBox(height: 20.h),

          // ========== TIMELINE ==========
          _buildTimeline(dayAppointments),
          SizedBox(height: 24.h),

          // ========== APPOINTMENTS LIST ==========
          _buildAppointmentsList(dayAppointments),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  // ========== DATE NAVIGATION ==========
  Widget _buildDateNavigation(BuildContext context) {
    final previousDate = selectedDate.subtract(const Duration(days: 1));
    final nextDate = selectedDate.add(const Duration(days: 1));

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Day Button
          IconButton(
            icon: Icon(Icons.chevron_left, size: 24.sp),
            onPressed: () => onDateChanged(previousDate),
            tooltip: DateFormat('MMM dd').format(previousDate),
          ),

          // Current Date Display
          Column(
            children: [
              Text(
                DateFormat('EEEE').format(selectedDate),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                DateFormat('MMM dd, yyyy').format(selectedDate),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Next Day Button
          IconButton(
            icon: Icon(Icons.chevron_right, size: 24.sp),
            onPressed: () => onDateChanged(nextDate),
            tooltip: DateFormat('MMM dd').format(nextDate),
          ),
        ],
      ),
    );
  }

  // ========== TIMELINE ==========
  Widget _buildTimeline(List<AppointmentModel> appointments) {
    if (appointments.isEmpty) {
      return Container(
        padding: EdgeInsets.all(32.w),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.calendar_today,
                size: 48.sp,
                color: Colors.grey[400],
              ),
              SizedBox(height: 12.h),
              Text(
                'No appointments today',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: _buildTimeSlots(appointments),
      ),
    );
  }

  List<Widget> _buildTimeSlots(List<AppointmentModel> allAppointments) {
    List<Widget> slots = [];

    // Sort by time
    allAppointments.sort(
        (a, b) => a.timeRange.start.hour.compareTo(b.timeRange.start.hour));

    for (int i = 0; i < 12; i++) {
      int hour = 8 + i;

      final appointmentsThisHour = allAppointments
          .where((apt) => apt.timeRange.start.hour == hour)
          .toList();

      slots.add(
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
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
                  '${hour.toString().padLeft(2, '0')}:00',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: 12.w),

              // Appointments
              Expanded(
                child: appointmentsThisHour.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: appointmentsThisHour
                            .asMap()
                            .entries
                            .map((entry) => Padding(
                                  padding: EdgeInsets.only(bottom: 8.h),
                                  child: _buildTimeSlotEvent(
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

    return slots;
  }

  // ========== TIME SLOT EVENT ==========
  Widget _buildTimeSlotEvent({
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
          // Time range
          Text(
            '${ScheduleUtils.formatTime(appointment.timeRange.start)} - ${ScheduleUtils.formatTime(appointment.timeRange.end)}',
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 6.h),

          // Patient name
          Text(
            appointment.patient?.name ?? 'Unknown Patient',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 3.h),

          // Diagnosis
          Text(
            appointment.patient?.diagnosis ?? 'No diagnosis',
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
            'Today\'s Schedule',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        if (appointments.isNotEmpty)
          ...appointments.asMap().entries.map((entry) {
            return _buildAppointmentCard(
              appointment: entry.value,
              colorIndex: entry.key,
            );
          }).toList()
        else
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Text(
                'No appointments today',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ========== APPOINTMENT CARD ==========
  Widget _buildAppointmentCard({
    required AppointmentModel appointment,
    required int colorIndex,
  }) {
    final bgColor = ScheduleUtils.getEventColor(colorIndex);
    final borderColor = ScheduleUtils.getEventBorderColor(colorIndex);

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: borderColor.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Time + Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14.sp, color: borderColor),
                    SizedBox(width: 6.w),
                    Text(
                      ScheduleUtils.formatTime(appointment.timeRange.start),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: borderColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: borderColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    'Scheduled',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: borderColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Patient Info
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Patient Name
                  Row(
                    children: [
                      Icon(Icons.person, size: 14.sp, color: Colors.grey),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          appointment.patient?.name ?? 'Unknown Patient',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),

                  // Diagnosis
                  Row(
                    children: [
                      Icon(Icons.healing, size: 14.sp, color: Colors.grey),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          appointment.patient?.diagnosis ??
                              'No diagnosis recorded',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (appointment.patient?.phone != null) ...[
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 14.sp, color: Colors.grey),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            appointment.patient!.phone,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (appointment.patient?.email != null) ...[
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(Icons.email, size: 14.sp, color: Colors.grey),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            appointment.patient!.email,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[700],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 12.h),

            // Doctor Info
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.medical_information, size: 12.sp),
                      SizedBox(width: 4.w),
                      Text(
                        appointment.doctor.name,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
