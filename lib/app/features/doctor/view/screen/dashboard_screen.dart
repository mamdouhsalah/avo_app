import 'package:avo_app/app/core/routing/app_router.dart';
import 'package:avo_app/app/core/shared/custom_avatar.dart';
import 'package:avo_app/app/core/shared/section_header.dart';

import 'package:avo_app/app/features/notification/view/screens/notification_screen.dart';
import 'package:avo_app/app/features/doctor/view/widget/custom_appointmentcard.dart';
import 'package:avo_app/app/features/doctor/view/widget/custom_drawer.dart';
import 'package:avo_app/app/features/doctor/view/widget/custom_stat_card.dart';
import 'package:avo_app/app/features/doctor/data/doctor_repository_impl.dart';
import 'package:avo_app/app/core/services/remote/firebase_consumer_impl.dart';
import 'package:avo_app/app/core/models/appointment_model.dart';
import 'package:avo_app/app/core/models/doctor_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ScrollController _scrollController = ScrollController();
  bool isVisible = true;
  late final DoctorRepositoryImpl _doctorRepo;
  final String _doctorId = FirebaseAuth.instance.currentUser?.uid ?? '';
  DoctorModel? currentDoctor;

  @override
  void initState() {
    _doctorRepo = DoctorRepositoryImpl(consumer: FirebaseConsumerImpl());
    _fetchDoctorData();
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _fetchDoctorData() async {
    try {
      final docData = await FirebaseConsumerImpl().get(
        'users/$_doctorId',
        fromJson: (json) => DoctorModel.fromJson(json),
      );
      setState(() => currentDoctor = docData);
    } catch (e) {
      // Ignore or handle
    }
  }

  void _scrollListener() {
    if (_scrollController.offset > 50 && isVisible) {
      setState(() => isVisible = false);
    } else if (_scrollController.offset <= 50 && !isVisible) {
      setState(() => isVisible = true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu,
                color: theme.textTheme.titleLarge?.color, size: 28),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'Dashboard',
          style: TextStyle(
            color: theme.textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      drawer: const CustomDrawer(),
      body: Stack(
        children: [
          // المحتوى الرئيسي
          SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.all(8.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomAvatar(
                      imageUrl: currentDoctor?.imageUrl,
                      size: 55.sp,
                      radius: 53.r,
                      borderColor: theme.colorScheme.primary,
                    ),
                    SizedBox(width: 8.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good Morning',
                          style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: theme.colorScheme.outlineVariant),
                        ),
                        Text(
                          currentDoctor != null ? 'Dr. ${currentDoctor!.name}' : 'Loading...',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.titleLarge?.color,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NotificationScreen()),
                        );
                      },
                      icon: Icon(Icons.notifications_none_outlined,
                          size: 34.sp, color: theme.colorScheme.outlineVariant),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Stats Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 1.h,
                  crossAxisSpacing: 1.w,
                  childAspectRatio: 1.25.sp,
                  padding: EdgeInsets.zero,
                  children: const [
                    StatCard(
                      title: 'Patients',
                      value: '1,248',
                      subtitle: '+12% from last month',
                      icon: Icons.people,
                      color: Color(0xFF4ECDC4),
                    ),
                    StatCard(
                      title: 'Appointment',
                      value: '500',
                      subtitle: '3 pending',
                      icon: Icons.calendar_today,
                      color: Color(0xFFFFB74D),
                    ),
                    StatCard(
                      title: 'Lab results',
                      value: '389',
                      subtitle: '2 urgent',
                      icon: Icons.science,
                      color: Color(0xFFFF6B6B),
                    ),
                    StatCard(
                      title: 'Prescriptions',
                      value: '156',
                      subtitle: '+12% from last month',
                      icon: Icons.medication,
                      color: Color(0xFF9B59B6),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SectionHeader(
                      title: 'Upcoming Appointments',
                      routePath: '/appointments'),
                ),
                const SizedBox(height: 16),

                StreamBuilder<List<AppointmentModel>>(
                  stream: _doctorRepo.streamDoctorAppointments(_doctorId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    final appointments = snapshot.data ?? [];
                    
                    if (appointments.isEmpty) {
                      return const Center(child: Text('No upcoming appointments'));
                    }

                    return ListView.separated(
                      itemCount: appointments.length > 5 ? 5 : appointments.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      separatorBuilder: (context, index) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        return CustomAppointmentCard(
                          appointment: appointments[index],
                        );
                      },
                    );
                  }
                ),

                SizedBox(height: 160.h), // مساحة إضافية
              ],
            ),
          ),

          // ==================== زرار الـ Chat Button ====================
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            bottom: 100.h,
            right: isVisible ? 16.w : -50.w,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: isVisible ? 1 : 0.8,
              child: GestureDetector(
                onTap: () {
                  context.push(AppRouter.chatBot);
                },
                child: Container(
                  width: 86.w,
                  height: 86.h,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2.w,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    width: 86.w,
                    height: 86.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context)
                          .colorScheme
                          .surface
                          .withValues(alpha: 0.85),
                    ),
                    child: Image.asset(
                      'assets/imgs/chatbut/chatbut.png',
                      color: Theme.of(context).colorScheme.primary,
                      colorBlendMode: BlendMode.srcIn,
                      height: 70.h,
                      width: 70.w,
                    ),
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
