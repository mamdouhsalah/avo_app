import 'package:avo_app/app/core/routing/app_router.dart';
import 'package:avo_app/app/core/constants/app_spacing.dart';
import 'package:avo_app/app/core/services/local/hive_models.dart';
import 'package:avo_app/app/features/reminder/screens/widgets/add_medication_fab.dart';
import 'package:avo_app/app/features/reminder/screens/widgets/calendar_strip_widget.dart';
import 'package:avo_app/app/features/reminder/screens/widgets/medication_detail_tile.dart';
import 'package:avo_app/app/features/schedule/logic/schedule_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/Language/locale_keys.g.dart';

/// Full schedule screen reachable from the "See All" link in [ReminderScreen].
///
/// ✅ CRASH FIX: [CalendarStripWidget] is outside [BlocBuilder].
/// Previously, state rebuilds caused [selectedDay] to reset to [DateTime.now()],
/// which triggered competing scroll commands in the CalendarStrip's internal
/// [PageController].
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ScheduleCubit>().loadForDate(_selectedDay);
    });
  }

  void _onDaySelected(DateTime day) {
    setState(() => _selectedDay = day);
    context.read<ScheduleCubit>().loadForDate(day);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(LocaleKeys.reminder_schedule.tr()),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRouter.addMedication),
            icon: Icon(
              Icons.edit_note_rounded,
              size: 26,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // ✅ STABLE: CalendarStripWidget lives OUTSIDE BlocBuilder
          CalendarStripWidget(
            selectedDay: _selectedDay,
            onDaySelected: _onDaySelected,
          ),

          SizedBox(height: AppSpacing.v16),

          // Only the content area rebuilds on cubit state changes
          Expanded(
            child: BlocBuilder<ScheduleCubit, ScheduleState>(
              builder: (context, state) => _buildContent(
                  context, state, context.read<ScheduleCubit>()),
            ),
          ),
        ],
      ),

      floatingActionButton: AddMedicationFab(
        onPressed: () async {
          await context.push(AppRouter.addMedication);
          // Reload after returning from add screen
          if (context.mounted) {
            context.read<ScheduleCubit>().loadForDate(_selectedDay);
          }
        },
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, ScheduleState state, ScheduleCubit cubit) {
    final theme = Theme.of(context);

    if (state is ScheduleLoading || state is ScheduleInitial) {
      return Center(
        child: CircularProgressIndicator(color: theme.colorScheme.primary),
      );
    }

    if (state is ScheduleError) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 48.sp, color: theme.colorScheme.error),
              SizedBox(height: 12.h),
              Text(
                state.error,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: theme.colorScheme.error, fontSize: 16.sp),
              ),
              SizedBox(height: 16.h),
              ElevatedButton.icon(
                onPressed: () => cubit.loadForDate(_selectedDay),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(LocaleKeys.schedule_retry.tr()),
              ),
            ],
          ),
        ),
      );
    }

    if (state is ScheduleLoaded) {
      final meds = state.medications;
      final apts = state.appointments;

      if (meds.isEmpty && apts.isEmpty) {
        return _buildEmptyState(context, state.selectedDate);
      }

      return ListView(
        padding:
            EdgeInsets.symmetric(horizontal: AppSpacing.h20, vertical: 8.h),
        children: [
          // ── Medications section ──
          if (meds.isNotEmpty) ...[
            _SectionLabel(
              icon: Icons.medication_rounded,
              label: LocaleKeys.schedule_medications_label.tr(),
              color: theme.colorScheme.primary,
            ),
            SizedBox(height: AppSpacing.v8),
            ...meds.map((med) => MedicationDetailTile(
                  reminder: med,
                  onMarkTaken: () => cubit.markAsTaken(med),
                  onMarkSkipped: () => cubit.markAsSkipped(med),
                  onDelete: () => cubit.deleteMedication(med),
                )),
          ],

          // ── Appointments section ──
          if (apts.isNotEmpty) ...[
            SizedBox(height: AppSpacing.v16),
            _SectionLabel(
              icon: Icons.calendar_today_rounded,
              label: LocaleKeys.schedule_appointments_label.tr(),
              color: Colors.orange,
            ),
            SizedBox(height: AppSpacing.v8),
            ...apts.map((apt) => _AppointmentCard(appointment: apt)),
          ],

          SizedBox(height: 80.h), // bottom FAB clearance
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildEmptyState(BuildContext context, DateTime date) {
    final theme = Theme.of(context);
    final isToday = _isSameDay(date, DateTime.now());
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_available_rounded,
                size: 64.sp, color: Colors.grey.shade400),
            SizedBox(height: 16.h),
            Text(
              isToday
                  ? LocaleKeys.schedule_empty_today.tr()
                  : LocaleKeys.schedule_empty_other_day.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8.h),
            Text(
              LocaleKeys.schedule_add_medication_hint.tr(),
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: theme.colorScheme.primary, fontSize: 14.sp),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ─── Helper widgets ────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SectionLabel(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18.sp),
        SizedBox(width: 8.w),
        Text(label,
            style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface)),
      ],
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;

  const _AppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final timeStr =
        '${appointment.dateTime.hour.toString().padLeft(2, '0')}:${appointment.dateTime.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.v12),
      padding: EdgeInsets.all(AppSpacing.h16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.calendar_month_rounded,
                color: Colors.orange, size: 24.sp),
          ),
          SizedBox(width: AppSpacing.h16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.title,
                  style: TextStyle(
                      fontSize: 15.sp, fontWeight: FontWeight.bold),
                ),
                if (appointment.location.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    appointment.location,
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 12.sp),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding:
                EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20.r)),
            child: Text(
              timeStr,
              style: TextStyle(
                  color: Colors.orange,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}