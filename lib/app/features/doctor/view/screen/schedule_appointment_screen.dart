import 'package:avo_app/app/features/doctor/view/widget/custom_day_view_widget.dart';
import 'package:avo_app/app/features/doctor/view/widget/custom_drawer.dart';
import 'package:avo_app/app/features/doctor/view/widget/month_view_widget.dart';
import 'package:avo_app/app/features/doctor/view/widget/week_view_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:avo_app/app/features/doctor/services/schedule_controller.dart';
import 'package:avo_app/app/features/doctor/services/schedule_utils.dart';
import 'package:avo_app/app/features/doctor/data/doctor_repository_impl.dart';
import 'package:avo_app/app/core/services/remote/firebase_consumer_impl.dart';
import 'package:avo_app/app/core/models/appointment_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScheduleAppointmentScreen extends StatefulWidget {
  const ScheduleAppointmentScreen({super.key});

  @override
  State<ScheduleAppointmentScreen> createState() =>
      _ScheduleAppointmentScreenState();
}

class _ScheduleAppointmentScreenState
    extends State<ScheduleAppointmentScreen> with TickerProviderStateMixin {
  int viewMode = 1; // 0=Day, 1=Week, 2=Month

  DateTime? _selectedDate;
  DateTime? _weekStart;

  DateTime get selectedDate => _selectedDate ?? DateTime.now();
  set selectedDate(DateTime value) => _selectedDate = value;

  DateTime get weekStart {
    _weekStart ??= ScheduleController.getWeekStart(selectedDate);
    return _weekStart!;
  }

  set weekStart(DateTime value) => _weekStart = value;

  late final DoctorRepositoryImpl _doctorRepo;
  final String _doctorId = FirebaseAuth.instance.currentUser?.uid ?? '';

  // Loading animation controller
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _weekStart = ScheduleController.getWeekStart(_selectedDate!);
    _doctorRepo = DoctorRepositoryImpl(consumer: FirebaseConsumerImpl());

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _showMonthWeekSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MonthWeekSelectorSheet(
        initialDate: selectedDate,
        onSelected: (pickedDate, weekStartDate) {
          setState(() {
            selectedDate = pickedDate;
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
        scrolledUnderElevation: 0,
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
        actions: [
          IconButton(
            icon: Icon(Icons.today_rounded,
                size: 24.sp, color: theme.colorScheme.primary),
            tooltip: 'Go to today',
            onPressed: () {
              setState(() {
                selectedDate = DateTime.now();
                weekStart = ScheduleController.getWeekStart(DateTime.now());
              });
            },
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: StreamBuilder<List<AppointmentModel>>(
            stream: _doctorRepo.streamDoctorAppointments(_doctorId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildShimmerLoader(theme);
              }
              if (snapshot.hasError) {
                return _buildErrorState(snapshot.error.toString(), theme);
              }
              final appointments = snapshot.data ?? [];

              return Column(
                children: [
                  SizedBox(height: 16.h),

                  // ========== HEADER ==========
                  _buildHeaderSection(theme, weekEnd, appointments),
                  SizedBox(height: 16.h),

                  // ========== VIEW MODE TABS ==========
                  _buildViewModeTabs(theme),
                  SizedBox(height: 16.h),

                  // ========== MAIN CONTENT ==========
                  Expanded(
                    child: _buildMainContent(theme, appointments),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ========== BEAUTIFUL SHIMMER LOADER ==========
  Widget _buildShimmerLoader(ThemeData theme) {
    final primary = theme.colorScheme.primary;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated calendar icon
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) => Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  size: 40.sp,
                  color: primary.withValues(alpha: _pulseAnimation.value),
                ),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'Loading your schedule...',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Fetching appointments from Firebase',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 32.h),
          // Progress dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              return AnimatedBuilder(
                animation: _pulseController,
                builder: (context, _) {
                  final delay = i * 0.3;
                  final value =
                      ((_pulseController.value + delay) % 1.0).clamp(0.0, 1.0);
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primary.withValues(alpha: 0.3 + value * 0.7),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // ========== ERROR STATE ==========
  Widget _buildErrorState(String error, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, size: 56.sp, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
            'Could not load schedule',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            error,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========== HEADER ==========
  Widget _buildHeaderSection(ThemeData theme, DateTime weekEnd,
      List<AppointmentModel> appointments) {
    final monthName = ScheduleUtils.formatMonth(selectedDate);
    final yearName = DateFormat('yyyy').format(selectedDate);
    final primary = theme.colorScheme.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              monthName,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[500],
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              yearName,
              style: TextStyle(
                fontSize: 26.sp,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        Row(
          children: [
            // Appointment count badge
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.event_note_rounded,
                      size: 14.sp, color: primary),
                  SizedBox(width: 6.w),
                  Text(
                    _getAppointmentCount(appointments),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: primary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            // Select date button
            GestureDetector(
              onTap: _showMonthWeekSelector,
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month, size: 14.sp, color: Colors.white),
                    SizedBox(width: 6.w),
                    Text(
                      'Jump to',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getAppointmentCount(List<AppointmentModel> appointments) {
    int count = 0;
    if (viewMode == 0) {
      count = ScheduleController.getAppointmentsForDate(
              selectedDate, appointments)
          .length;
    } else if (viewMode == 1) {
      count = ScheduleController.getAppointmentsForWeek(
              weekStart, appointments)
          .length;
    } else {
      count = ScheduleController.getAppointmentsForMonth(
              selectedDate, appointments)
          .length;
    }
    return '$count appt${count != 1 ? 's' : ''}';
  }

  // ========== VIEW MODE TABS ==========
  Widget _buildViewModeTabs(ThemeData theme) {
    final primary = theme.colorScheme.primary;
    return Container(
      padding: EdgeInsets.all(4.h),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          _buildViewTab(
            icon: Icons.calendar_today_rounded,
            label: 'Day',
            isSelected: viewMode == 0,
            onTap: () => setState(() => viewMode = 0),
            theme: theme,
            primary: primary,
          ),
          SizedBox(width: 4.w),
          _buildViewTab(
            icon: Icons.calendar_view_week_rounded,
            label: 'Week',
            isSelected: viewMode == 1,
            onTap: () => setState(() => viewMode = 1),
            theme: theme,
            primary: primary,
          ),
          SizedBox(width: 4.w),
          _buildViewTab(
            icon: Icons.calendar_view_month_rounded,
            label: 'Month',
            isSelected: viewMode == 2,
            onTap: () => setState(() => viewMode = 2),
            theme: theme,
            primary: primary,
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
    required Color primary,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18.sp,
                color: isSelected
                    ? Colors.white
                    : Colors.grey[500],
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========== MAIN CONTENT ==========
  Widget _buildMainContent(
      ThemeData theme, List<AppointmentModel> appointments) {
    switch (viewMode) {
      case 0: // Day View
        return DayViewWidget(
          selectedDate: selectedDate,
          appointments: appointments,
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
          appointments: appointments,
          onDateSelected: (date) {
            setState(() {
              selectedDate = date;
              weekStart = ScheduleController.getWeekStart(date);
            });
          },
        );
      case 2: // Month View
      default:
        return MonthViewWidget(
          initialDate: selectedDate,
          appointments: appointments,
          onDaySelected: (date) {
            setState(() {
              selectedDate = date;
              weekStart = ScheduleController.getWeekStart(date);
            });
          },
        );
    }
  }
}
