import 'package:avo_app/app/features/doctor/services/schedule_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:avo_app/app/core/models/appointment_model.dart';
import 'package:avo_app/app/features/doctor/services/schedule_controller.dart';

class WeekViewWidget extends StatefulWidget {
  final DateTime weekStart;
  final List<AppointmentModel> appointments;
  final Function(DateTime) onDateSelected;

  const WeekViewWidget({
    super.key,
    required this.weekStart,
    required this.appointments,
    required this.onDateSelected,
  });

  @override
  State<WeekViewWidget> createState() => _WeekViewWidgetState();
}

class _WeekViewWidgetState extends State<WeekViewWidget> {
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    // Default selected day = today if today is within this week, else weekStart
    final today = DateTime.now();
    final weekEnd = widget.weekStart.add(const Duration(days: 6));
    if (!today.isBefore(widget.weekStart) &&
        !today.isAfter(weekEnd)) {
      _selectedDay = DateTime(today.year, today.month, today.day);
    } else {
      _selectedDay = widget.weekStart;
    }
  }

  @override
  void didUpdateWidget(WeekViewWidget old) {
    super.didUpdateWidget(old);
    if (old.weekStart != widget.weekStart) {
      final today = DateTime.now();
      final weekEnd = widget.weekStart.add(const Duration(days: 6));
      if (!today.isBefore(widget.weekStart) && !today.isAfter(weekEnd)) {
        _selectedDay = DateTime(today.year, today.month, today.day);
      } else {
        _selectedDay = widget.weekStart;
      }
    }
  }

  List<AppointmentModel> get _dayAppointments =>
      ScheduleController.getAppointmentsForDate(_selectedDay, widget.appointments);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ========== DAYS HEADER ==========
          _buildDaysHeader(primary),
          SizedBox(height: 16.h),

          // ========== SELECTED DAY LABEL ==========
          Padding(
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
                  DateFormat('EEEE, MMM dd').format(_selectedDay),
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
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
                    '${_dayAppointments.length} appointment${_dayAppointments.length != 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),

          // ========== TIMELINE ==========
          _buildTimeline(_dayAppointments, primary),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  // ========== DAYS HEADER ==========
  Widget _buildDaysHeader(Color primary) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (index) {
          final date = widget.weekStart.add(Duration(days: index));
          final dayName = DateFormat('EEE').format(date);
          final dayNumber = date.day.toString();
          final isToday = ScheduleController.isToday(date);
          final isSelected = date.year == _selectedDay.year &&
              date.month == _selectedDay.month &&
              date.day == _selectedDay.day;
          final hasAppts = widget.appointments.any((a) =>
              a.date.year == date.year &&
              a.date.month == date.month &&
              a.date.day == date.day);

          return GestureDetector(
            onTap: () {
              setState(() => _selectedDay = date);
              widget.onDateSelected(date);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? primary
                    : isToday
                        ? primary.withValues(alpha: 0.15)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(10.r),
                border: isToday && !isSelected
                    ? Border.all(color: primary.withValues(alpha: 0.4), width: 1)
                    : null,
              ),
              child: Column(
                children: [
                  Text(
                    dayName,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 11.sp,
                      color: isSelected
                          ? Colors.white
                          : isToday
                              ? primary
                              : Colors.black54,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    dayNumber,
                    style: TextStyle(
                      fontWeight: isSelected || isToday
                          ? FontWeight.bold
                          : FontWeight.w500,
                      fontSize: 13.sp,
                      color: isSelected
                          ? Colors.white
                          : isToday
                              ? primary
                              : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  // Appointment dot indicator
                  Container(
                    width: 5.w,
                    height: 5.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: hasAppts
                          ? (isSelected ? Colors.white : primary)
                          : Colors.transparent,
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

  // ========== TIMELINE ==========
  Widget _buildTimeline(List<AppointmentModel> dayAppts, Color primary) {
    if (dayAppts.isEmpty) {
      return Container(
        padding: EdgeInsets.all(32.w),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.event_available,
                  size: 52.sp, color: Colors.grey[300]),
              SizedBox(height: 12.h),
              Text(
                'No appointments on this day',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                DateFormat('EEEE, MMMM d').format(_selectedDay),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Sort appointments by time
    final sorted = [...dayAppts]
      ..sort((a, b) => a.startHour.compareTo(b.startHour));

    return Column(
      children: sorted.asMap().entries.map((entry) {
        return _buildAppointmentCard(entry.value, entry.key, primary);
      }).toList(),
    );
  }

  Widget _buildAppointmentCard(
      AppointmentModel apt, int index, Color primary) {
    final color = ScheduleUtils.getEventColor(index);
    final borderColor = ScheduleUtils.getEventBorderColor(index);

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: borderColor.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: borderColor.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left accent bar
            Container(
              width: 4.w,
              height: 60.h,
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: 14.w),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time badge
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 12.sp, color: borderColor),
                      SizedBox(width: 4.w),
                      Text(
                        '${apt.startTime} – ${apt.endTime}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: borderColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),

                  // Patient name
                  Text(
                    apt.patientName ?? 'Patient',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),

                  // Notes / Diagnosis
                  if (apt.notes != null && apt.notes!.isNotEmpty)
                    Row(
                      children: [
                        Icon(Icons.notes_rounded,
                            size: 11.sp, color: Colors.grey[500]),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            apt.notes!,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Status chip
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                apt.status[0].toUpperCase() + apt.status.substring(1),
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: borderColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
