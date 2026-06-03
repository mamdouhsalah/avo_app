import 'package:avo_app/app/features/doctor/view/widget/custom_dayViewWidget.dart';
import 'package:avo_app/app/features/doctor/view/widget/custom_drawer.dart';
import 'package:avo_app/app/features/doctor/view/widget/month_view_widget.dart';
import 'package:avo_app/app/features/doctor/view/widget/week_view_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:avo_app/app/features/doctor/services/schedule_controller.dart';
import 'package:avo_app/app/features/doctor/services/schedule_utils.dart';

class ScheduleAppointmentScreen extends StatefulWidget {
  const ScheduleAppointmentScreen({super.key});

  @override
  State<ScheduleAppointmentScreen> createState() =>
      _ScheduleAppointmentScreenState();
}

class _ScheduleAppointmentScreenState extends State<ScheduleAppointmentScreen> {
  int viewMode = 1;

  DateTime? _selectedDate;
  DateTime? _weekStart;

  DateTime get selectedDate => _selectedDate ?? DateTime.now();
  set selectedDate(DateTime value) => _selectedDate = value;

  DateTime get weekStart {
    if (_weekStart == null) {
      _weekStart = ScheduleController.getWeekStart(selectedDate);
    }
    return _weekStart!;
  }

  set weekStart(DateTime value) => _weekStart = value;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _weekStart = ScheduleController.getWeekStart(_selectedDate!);
  }

  void _showMonthWeekSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MonthWeekSelectorSheet(
        initialDate: selectedDate,
        onSelected: (monthDate, weekStartDate) {
          setState(() {
            selectedDate = monthDate;
            weekStart = weekStartDate;
            viewMode = 1; // Switch to week view
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weekEnd = ScheduleController.getWeekEnd(weekStart);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Schedule',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(
              Icons.menu,
              size: 24.sp,
              color: theme.textTheme.titleLarge?.color,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const CustomDrawer(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              SizedBox(height: 16.h),

              // ========== HEADER WITH MONTH/WEEK SELECTOR ==========
              _buildHeaderSection(theme, weekEnd),
              SizedBox(height: 20.h),

              // ========== VIEW MODE TABS ==========
              _buildViewModeTabs(theme),
              SizedBox(height: 20.h),

              // ========== MAIN CONTENT ==========
              Expanded(
                child: _buildMainContent(theme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========== HEADER WITH MONTH/WEEK SELECTOR ==========
  Widget _buildHeaderSection(ThemeData theme, DateTime weekEnd) {
    final monthName = ScheduleUtils.formatMonth(selectedDate);
    final yearName = DateFormat('yyyy').format(selectedDate);

    return Column(
      children: [
        // Top row with month and quick selector
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  monthName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  yearName,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: _showMonthWeekSelector,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_month,
                      size: 18.sp,
                      color: theme.colorScheme.primary,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Select',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 16.h),

        // Date range display
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      viewMode == 0
                          ? 'Today'
                          : viewMode == 1
                              ? 'This Week'
                              : 'This Month',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      viewMode == 0
                          ? DateFormat('MMM dd, yyyy').format(selectedDate)
                          : viewMode == 1
                              ? ScheduleUtils.formatDateRange(
                                  weekStart, weekEnd)
                              : ScheduleUtils.formatMonthYear(selectedDate),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  _getAppointmentCount(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getAppointmentCount() {
    int count = 0;
    if (viewMode == 0) {
      count = ScheduleController.getAppointmentsForDate(selectedDate).length;
    } else if (viewMode == 1) {
      count = ScheduleController.getAppointmentsForWeek(weekStart).length;
    } else {
      count = ScheduleController.getAppointmentsForMonth(selectedDate).length;
    }
    return '$count Appointment${count != 1 ? 's' : ''}';
  }

  // ========== VIEW MODE TABS ==========
  Widget _buildViewModeTabs(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.h),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          // Day View
          Expanded(
            child: _buildViewTab(
              icon: Icons.calendar_today,
              label: 'Day',
              isSelected: viewMode == 0,
              onTap: () => setState(() => viewMode = 0),
              theme: theme,
            ),
          ),
          SizedBox(width: 6.w),

          // Week View
          Expanded(
            child: _buildViewTab(
              icon: Icons.calendar_view_week,
              label: 'Week',
              isSelected: viewMode == 1,
              onTap: () => setState(() => viewMode = 1),
              theme: theme,
            ),
          ),
          SizedBox(width: 6.w),

          // Month View
          Expanded(
            child: _buildViewTab(
              icon: Icons.calendar_view_month,
              label: 'Month',
              isSelected: viewMode == 2,
              onTap: () => setState(() => viewMode = 2),
              theme: theme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewTab({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18.sp,
              color: isSelected ? Colors.white : Colors.grey,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== MAIN CONTENT ==========
  Widget _buildMainContent(ThemeData theme) {
    switch (viewMode) {
      case 0: // Day View
        return DayViewWidget(
          selectedDate: selectedDate,
          onDateChanged: (date) {
            setState(() {
              selectedDate = date;
              weekStart = ScheduleController.getWeekStart(date);
            });
          },
        );
      case 1: // Week View
        return WeekViewWidget(
          weekStart: weekStart,
          onDateSelected: (date) {
            setState(() {
              selectedDate = date;
              weekStart = ScheduleController.getWeekStart(date);
            });
          },
        );
      case 2: // Month View
      default:
        return MonthWeekSelectorSheet(
          initialDate: selectedDate,
          onSelected: (monthDate, weekStartDate) {
            setState(() {
              selectedDate = monthDate;
              weekStart = weekStartDate;
              viewMode = 1; // Switch to week view
            });
          },
        );
    }
  }
}
