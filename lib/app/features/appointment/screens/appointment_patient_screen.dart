import 'package:avo_app/app/features/appointment/logic/appointment_cubit.dart';
import 'package:avo_app/app/features/appointment/logic/appointment_state.dart';
import 'package:avo_app/app/features/appointment/screens/canceled_appointments.dart';
import 'package:avo_app/app/features/appointment/screens/completed_appointments.dart';
import 'package:avo_app/app/features/appointment/screens/upcomming_appointments.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/Language/locale_keys.g.dart';

class AppointmentPatientScreen extends StatefulWidget {
  const AppointmentPatientScreen({super.key});

  @override
  State<AppointmentPatientScreen> createState() => _AppointmentPatientScreenState();
}

class _AppointmentPatientScreenState extends State<AppointmentPatientScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AppointmentCubit>().getAppointments();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DefaultTabController(
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
        body: SafeArea(
          child: BlocBuilder<AppointmentCubit, AppointmentState>(
            builder: (context, state) {
              if (state is AppointmentLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is AppointmentError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.message),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () =>
                            context.read<AppointmentCubit>().getAppointments(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final cubit = context.read<AppointmentCubit>();

              return TabBarView(
                children: [
                  UpcomingAppointmentsScreen(
                    appointmentCards: cubit.upcomingAppointments,
                  ),
                  CompletedAppointmentsScreen(
                    completedAppointments: cubit.completedAppointments,
                  ),
                  CanceledAppointmentsScreen(
                    canceledAppointments: cubit.canceledAppointments,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}