import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:avo_app/app/core/models/appointment_model.dart';
import 'package:avo_app/app/features/doctor/services/schedule_controller.dart';
import 'package:avo_app/app/features/doctor/services/schedule_utils.dart';

class DayViewWidget extends StatelessWidget {
  final DateTime selectedDate;
  final List<AppointmentModel> appointments;
  final Function(DateTime) onDateChanged;

  const DayViewWidget({
    super.key,
    required this.selectedDate,
    required this.appointments,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final dayAppointments =
        ScheduleController.getAppointmentsForDate(selectedDate, appointments);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ========== DATE NAVIGATION ==========
          _buildDateNavigation(context, primary),
          SizedBox(height: 20.h),

          // ========== TIMELINE SUMMARY ==========
          _buildTimelineSummary(dayAppointments, primary),
          SizedBox(height: 24.h),

          // ========== APPOINTMENTS TIMELINE ==========
          _buildAppointmentsTimeline(dayAppointments, primary),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  // ========== DATE NAVIGATION ==========
  Widget _buildDateNavigation(BuildContext context, Color primary) {
    final previousDate = selectedDate.subtract(const Duration(days: 1));
    final nextDate = selectedDate.add(const Duration(days: 1));
    final isToday = ScheduleController.isToday(selectedDate);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isToday
            ? primary.withValues(alpha: 0.05)
            : Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: isToday
            ? Border.all(color: primary.withValues(alpha: 0.2))
            : Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Day Button
          IconButton(
            icon: Icon(Icons.chevron_left, size: 28.sp, color: primary),
            onPressed: () => onDateChanged(previousDate),
            tooltip: DateFormat('MMM dd').format(previousDate),
          ),

          // Current Date Display
          Column(
            children: [
              Text(
                isToday ? 'Today' : DateFormat('EEEE').format(selectedDate),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: isToday ? primary : Colors.grey[600],
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                DateFormat('MMM dd, yyyy').format(selectedDate),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),

          // Next Day Button
          IconButton(
            icon: Icon(Icons.chevron_right, size: 28.sp, color: primary),
            onPressed: () => onDateChanged(nextDate),
            tooltip: DateFormat('MMM dd').format(nextDate),
          ),
        ],
      ),
    );
  }

  // ========== TIMELINE SUMMARY ==========
  Widget _buildTimelineSummary(
      List<AppointmentModel> dayAppointments, Color primary) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 18.h,
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            'Daily Schedule',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              '${dayAppointments.length} appointment${dayAppointments.length != 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========== APPOINTMENTS TIMELINE ==========
  Widget _buildAppointmentsTimeline(
      List<AppointmentModel> appointments, Color primary) {
    if (appointments.isEmpty) {
      return Container(
        padding: EdgeInsets.all(40.w),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        ),
        child: Center(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.coffee_rounded,
                  size: 48.sp,
                  color: Colors.grey[400],
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'No appointments today',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Enjoy your free time!',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Create a continuous timeline from 8 AM to 8 PM
    List<Widget> timelineSlots = [];
    appointments.sort((a, b) => a.startHour.compareTo(b.startHour));

    // Find the earliest and latest hour to limit the scroll range slightly if desired,
    // or just show a fixed 8 AM - 8 PM range. We'll use fixed for consistency.
    for (int hour = 8; hour <= 20; hour++) {
      final apptsForHour =
          appointments.where((a) => a.startHour == hour).toList();

      timelineSlots.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Time column
              SizedBox(
                width: 60.w,
                child: Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text(
                    '${hour > 12 ? hour - 12 : hour}:00 ${hour >= 12 ? 'PM' : 'AM'}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
              SizedBox(width: 12.w),

              // Timeline line & dots
              Column(
                children: [
                  Container(
                    width: 12.w,
                    height: 12.w,
                    margin: EdgeInsets.only(top: 10.h),
                    decoration: BoxDecoration(
                      color: apptsForHour.isNotEmpty
                          ? primary
                          : Colors.grey.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                      boxShadow: apptsForHour.isNotEmpty
                          ? [
                              BoxShadow(
                                color: primary.withValues(alpha: 0.3),
                                blurRadius: 4,
                                spreadRadius: 1,
                              )
                            ]
                          : [],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: 2.w,
                      color: Colors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 16.w),

              // Appointments cards
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 24.h),
                  child: apptsForHour.isNotEmpty
                      ? Column(
                          children: apptsForHour.asMap().entries.map((entry) {
                            return _buildDayAppointmentCard(
                                entry.value, entry.key);
                          }).toList(),
                        )
                      : const SizedBox(height: 40), // Empty space for this hour
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(children: timelineSlots);
  }

  Widget _buildDayAppointmentCard(AppointmentModel apt, int index) {
    final colors = [
      const Color(0xFFEAF6FF),
      const Color(0xFFF0FFF4),
      const Color(0xFFFFF7E6),
      const Color(0xFFF9F0FF),
    ];
    final borders = [
      const Color(0xFF4A90D9),
      const Color(0xFF27AE60),
      const Color(0xFFE67E22),
      const Color(0xFF8E44AD),
    ];
    // We use the patient name length as a simple deterministic hash so the colors stay consistent for the same appt
    final hash = apt.patientName?.length ?? index;
    final bgColor = colors[hash % colors.length];
    final borderColor = borders[hash % borders.length];

    return Padding(
      padding: EdgeInsets.only(top: 4.h, bottom: 8.h),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: borderColor.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: borderColor.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14.r),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Colored left border
                Container(
                  width: 5.w,
                  color: borderColor,
                ),
                
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Time & Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.access_time_filled,
                                    size: 14.sp, color: borderColor),
                                SizedBox(width: 4.w),
                                Text(
                                  '${apt.startTime} – ${apt.endTime}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: borderColor,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(6.r),
                                border: Border.all(
                                    color: borderColor.withValues(alpha: 0.2)),
                              ),
                              child: Text(
                                apt.status[0].toUpperCase() +
                                    apt.status.substring(1),
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w700,
                                  color: borderColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),

                        // Patient Info
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: borderColor.withValues(alpha: 0.2)),
                              ),
                              child: Icon(Icons.person,
                                  size: 16.sp, color: borderColor),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    apt.patientName ?? 'Unknown Patient',
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (apt.notes != null && apt.notes!.isNotEmpty) ...[
                                    SizedBox(height: 4.h),
                                    Text(
                                      apt.notes!,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey[700],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
