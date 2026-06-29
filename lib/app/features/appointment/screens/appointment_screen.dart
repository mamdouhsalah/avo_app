import 'package:avo_app/app/features/appointment/logic/appointment_cubit.dart';
import 'package:avo_app/app/features/appointment/screens/canceled_appointments.dart';
import 'package:avo_app/app/features/appointment/screens/completed_appointments.dart';
import 'package:avo_app/app/features/appointment/screens/upcomming_appointments.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/Language/locale_keys.g.dart';

class AppoiontmentScreen extends StatelessWidget {
  const AppoiontmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocProvider(
      create: (_) => sl<AppointmentCubit>()..getAppointments(),
      child: DefaultTabController(
        length: 3,
        animationDuration: const Duration(milliseconds: 300),
        initialIndex: 0,
        child: Scaffold(
          appBar: AppBar(
            title: Text(LocaleKeys.appointment_title.tr()),
            centerTitle: true,
            bottom: TabBar(
              dividerColor: Colors.transparent,
              indicatorWeight: 1.h,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: colorScheme.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: colorScheme.primary,
              tabs: [
                Tab(text: LocaleKeys.appointment_upcoming.tr()),
                Tab(text: LocaleKeys.appointment_completed.tr()),
                Tab(text: LocaleKeys.appointment_canceled.tr()),
              ],
              labelPadding: EdgeInsets.symmetric(vertical: 0.h),
            ),
          ),
          body: const SafeArea(
            child: TabBarView(
              children: [
                UpcomingAppointmentsScreen(),
                CompletedAppointmentsScreen(),
                CanceledAppointmentsScreen(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}