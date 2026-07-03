import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:avo_app/app/core/models/appointment_model.dart';
import 'package:avo_app/app/features/doctor/services/schedule_controller.dart';

class MonthViewWidget extends StatefulWidget {
  final DateTime initialDate;
  final List<AppointmentModel> appointments;
  final Function(DateTime) onDaySelected;

  const MonthViewWidget({
    super.key,
    required this.initialDate,
    required this.appointments,
    required this.onDaySelected,
  });

  @override
  State<MonthViewWidget> createState() => _MonthViewWidgetState();
}

class _MonthViewWidgetState extends State<MonthViewWidget> {
  late DateTime _currentMonth;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _currentMonth =
        DateTime(widget.initialDate.year, widget.initialDate.month, 1);
    _selectedDay = DateTime(widget.initialDate.year, widget.initialDate.month,
        widget.initialDate.day);
  }

  int get _daysInMonth =>
      DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;

  // First weekday of month (1=Mon, 7=Sun), adjust to 0-indexed Mon start
  int get _firstWeekdayOffset {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    return (firstDay.weekday - 1) % 7; // Mon=0 ... Sun=6
  }

  List<AppointmentModel> _appointmentsForDay(DateTime day) =>
      ScheduleController.getAppointmentsForDate(day, widget.appointments);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final today = DateTime.now();

    final dayAppts = _appointmentsForDay(_selectedDay);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ========== MONTH HEADER ==========
          _buildMonthHeader(primary),
          SizedBox(height: 12.h),

          // ========== WEEKDAY LABELS ==========
          _buildWeekdayLabels(),
          SizedBox(height: 8.h),

          // ========== CALENDAR GRID ==========
          _buildCalendarGrid(primary, today),
          SizedBox(height: 20.h),

          // ========== SELECTED DAY APPOINTMENTS ==========
          _buildDayAppointments(dayAppts, primary),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildMonthHeader(Color primary) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left, size: 28.sp, color: primary),
          onPressed: () => setState(() {
            _currentMonth = DateTime(
                _currentMonth.year, _currentMonth.month - 1, 1);
          }),
        ),
        Text(
          DateFormat('MMMM yyyy').format(_currentMonth),
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: Icon(Icons.chevron_right, size: 28.sp, color: primary),
          onPressed: () => setState(() {
            _currentMonth = DateTime(
                _currentMonth.year, _currentMonth.month + 1, 1);
          }),
        ),
      ],
    );
  }

  Widget _buildWeekdayLabels() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      children: days
          .map(
            (d) => Expanded(
              child: Center(
                child: Text(
                  d,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildCalendarGrid(Color primary, DateTime today) {
    final totalCells = _firstWeekdayOffset + _daysInMonth;
    final rows = (totalCells / 7).ceil();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.85,
      ),
      itemCount: rows * 7,
      itemBuilder: (context, index) {
        final dayIndex = index - _firstWeekdayOffset + 1;
        if (dayIndex < 1 || dayIndex > _daysInMonth) {
          return const SizedBox();
        }

        final date =
            DateTime(_currentMonth.year, _currentMonth.month, dayIndex);
        final isToday = date.year == today.year &&
            date.month == today.month &&
            date.day == today.day;
        final isSelected = date.year == _selectedDay.year &&
            date.month == _selectedDay.month &&
            date.day == _selectedDay.day;
        final appts = _appointmentsForDay(date);
        final hasAppts = appts.isNotEmpty;

        return GestureDetector(
          onTap: () {
            setState(() => _selectedDay = date);
            widget.onDaySelected(date);
          },
          child: Padding(
            padding: EdgeInsets.all(2.w),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                color: isSelected
                    ? primary
                    : isToday
                        ? primary.withValues(alpha: 0.12)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(10.r),
                border: isToday && !isSelected
                    ? Border.all(color: primary.withValues(alpha: 0.5), width: 1)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$dayIndex',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight:
                          isSelected || isToday ? FontWeight.bold : FontWeight.w400,
                      color: isSelected
                          ? Colors.white
                          : isToday
                              ? primary
                              : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  // Dot indicator
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
          ),
        );
      },
    );
  }

  Widget _buildDayAppointments(
      List<AppointmentModel> appts, Color primary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
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
              DateFormat('EEEE, MMMM d').format(_selectedDay),
              style: TextStyle(
                fontSize: 15.sp,
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
                '${appts.length} appt${appts.length != 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: primary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        if (appts.isEmpty)
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.event_available,
                      size: 40.sp, color: Colors.grey[300]),
                  SizedBox(height: 8.h),
                  Text(
                    'No appointments on this day',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...appts.asMap().entries.map((e) =>
              _buildAppointmentCard(e.value, e.key, primary)),
      ],
    );
  }

  Widget _buildAppointmentCard(
      AppointmentModel apt, int index, Color primary) {
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
    final bgColor = colors[index % colors.length];
    final borderColor = borders[index % borders.length];

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: borderColor.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: borderColor.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 4.w,
              height: 52.h,
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
                  SizedBox(height: 5.h),
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
                  if (apt.notes != null && apt.notes!.isNotEmpty) ...[
                    SizedBox(height: 3.h),
                    Text(
                      apt.notes!,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
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

// ======= Month + Week Selector Bottom Sheet (kept for backward compat) =======
class MonthWeekSelectorSheet extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime monthDate, DateTime weekStart) onSelected;

  const MonthWeekSelectorSheet({
    super.key,
    required this.initialDate,
    required this.onSelected,
  });

  @override
  State<MonthWeekSelectorSheet> createState() =>
      _MonthWeekSelectorSheetState();
}

class _MonthWeekSelectorSheetState extends State<MonthWeekSelectorSheet> {
  late DateTime _currentMonth;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(
        widget.initialDate.year, widget.initialDate.month, 1);
    _selectedDay = DateTime(widget.initialDate.year, widget.initialDate.month,
        widget.initialDate.day);
  }

  int get _daysInMonth =>
      DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;

  int get _firstWeekdayOffset {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    return (firstDay.weekday - 1) % 7;
  }

  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: (date.weekday - 1) % 7));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final today = DateTime.now();
    final rows =
        ((_firstWeekdayOffset + _daysInMonth) / 7).ceil();

    return Container(
      height: 560.h,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 8.h),

          // Month navigation
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left, size: 26.sp, color: primary),
                  onPressed: () => setState(() {
                    _currentMonth = DateTime(
                        _currentMonth.year, _currentMonth.month - 1, 1);
                  }),
                ),
                Text(
                  DateFormat('MMMM yyyy').format(_currentMonth),
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right, size: 26.sp, color: primary),
                  onPressed: () => setState(() {
                    _currentMonth = DateTime(
                        _currentMonth.year, _currentMonth.month + 1, 1);
                  }),
                ),
              ],
            ),
          ),

          // Weekday labels
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                  .map(
                    (d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          SizedBox(height: 6.h),

          // Calendar grid
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1.1,
                ),
                itemCount: rows * 7,
                itemBuilder: (context, index) {
                  final dayIndex = index - _firstWeekdayOffset + 1;
                  if (dayIndex < 1 || dayIndex > _daysInMonth) {
                    return const SizedBox();
                  }
                  final date = DateTime(
                      _currentMonth.year, _currentMonth.month, dayIndex);
                  final isToday = date.year == today.year &&
                      date.month == today.month &&
                      date.day == today.day;
                  final isSelected = date.year == _selectedDay.year &&
                      date.month == _selectedDay.month &&
                      date.day == _selectedDay.day;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedDay = date),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? primary
                            : isToday
                                ? primary.withValues(alpha: 0.12)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(8.r),
                        border: isToday && !isSelected
                            ? Border.all(
                                color: primary.withValues(alpha: 0.5),
                                width: 1)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '$dayIndex',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: isSelected || isToday
                                ? FontWeight.bold
                                : FontWeight.w400,
                            color: isSelected
                                ? Colors.white
                                : isToday
                                    ? primary
                                    : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Confirm button
          Padding(
            padding: EdgeInsets.all(16.w),
            child: SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: () {
                  widget.onSelected(_selectedDay, _getWeekStart(_selectedDay));
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Go to selected date',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
