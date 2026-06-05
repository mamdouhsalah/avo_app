import 'package:avo_app/app/features/doctor/data/data.dart';
import 'package:avo_app/app/features/doctor/view/widget/custom_appointmentcard.dart';
import 'package:avo_app/app/features/doctor/view/widget/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  bool isUpcoming = true;
  bool isGridView = false; // false = List View, true = Grid View

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final now = DateTime.now();

    final todayAppointments = DataRepository.appointments.where((appointment) {
      final appointmentDateTime = DateTime(
        appointment.date.year,
        appointment.date.month,
        appointment.date.day,
        appointment.timeRange.start.hour,
        appointment.timeRange.start.minute,
      );

      final isToday = appointment.date.year == now.year &&
          appointment.date.month == now.month &&
          appointment.date.day == now.day;

      if (isUpcoming) {
        return isToday && appointmentDateTime.isAfter(now);
      } else {
        return appointmentDateTime.isBefore(now);
      }
    }).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Appointments',
          style: TextStyle(
            color: theme.textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
            fontSize: 24.sp,
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
              color: theme.textTheme.titleLarge?.color,
              size: 24.sp,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const CustomDrawer(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),

            Text(
              "Today’s Overview",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
              ),
            ),

            SizedBox(height: 16.h),

            // Stats Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard("Total",
                    DataRepository.appointments.length.toString(), Colors.blue),
                _buildStatCard(
                  "Confirmed",
                  DataRepository.appointments
                      .where((e) => e.isFavorite)
                      .length
                      .toString(),
                  const Color(0xFF00B8A9),
                ),
                _buildStatCard(
                  "Pending",
                  DataRepository.appointments
                      .where((e) => !e.isFavorite)
                      .length
                      .toString(),
                  Colors.orange,
                ),
                _buildStatCard(
                  "Available",
                  todayAppointments.length.toString(),
                  Colors.grey,
                ),
              ],
            ),

            SizedBox(height: 24.h),

            // Tabs + View Toggle
            Row(
              children: [
                // Upcoming / Past Tabs
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => isUpcoming = true),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              color: isUpcoming
                                  ? const Color(0xFF00B8A9)
                                  : Colors.transparent,
                            ),
                            child: Center(
                              child: Text(
                                "Upcoming Appointment",
                                style: TextStyle(
                                  color: isUpcoming
                                      ? Colors.white
                                      : Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12.sp,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => isUpcoming = false),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            decoration: BoxDecoration(
                              color: !isUpcoming
                                  ? const Color(0xFF00B8A9)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Center(
                              child: Text(
                                "Past Appointment",
                                style: TextStyle(
                                  color: !isUpcoming
                                      ? Colors.white
                                      : Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12.sp,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // View Toggle Icon
                IconButton(
                  onPressed: () {
                    setState(() {
                      isGridView = !isGridView;
                    });
                  },
                  icon: Icon(
                    isGridView
                        ? Icons.view_list_rounded
                        : Icons.grid_view_rounded,
                    color: theme.textTheme.bodyMedium?.color
                        ?.withValues(alpha: 0.5),
                    size: 26.sp,
                  ),
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // Appointments List / Grid
            Expanded(
              child: todayAppointments.isEmpty
                  ? Center(
                      child: Text(
                        isUpcoming
                            ? "No Upcoming Appointments"
                            : "No Past Appointments",
                        style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                      ),
                    )
                  : isGridView
                      ? GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12.w,
                            mainAxisSpacing: 12.h,
                            childAspectRatio: 0.8, // اضبط حسب تصميم الكارت
                          ),
                          itemCount: todayAppointments.length,
                          itemBuilder: (context, index) {
                            return CustomGridAppointmentCard(
                              appointment: todayAppointments[index],
                            );
                          },
                        )
                      : ListView.separated(
                          itemCount: todayAppointments.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 12.h),
                          itemBuilder: (context, index) {
                            return CustomAppointmentCard(
                              appointment: todayAppointments[index],
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      alignment: Alignment.center,
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 36.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }
}
