import 'package:avo_app/app/core/constants/app_spacing.dart';
import 'package:avo_app/app/core/services/local/hive_models.dart';
import 'package:avo_app/app/features/reminder/data/reminder_model.dart';
import 'package:avo_app/app/features/schedule/logic/schedule_cubit.dart';
import 'package:avo_app/app/features/schedule/widgets/calender_section.dart';
import 'package:avo_app/app/features/schedule/widgets/scheduale_header.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui' as ui;

import '../../../core/Language/locale_keys.g.dart';

/// Patient-facing full-schedule screen.
///
/// Layout:
///   ┌─────────────────────────────┐
///   │  ScheduleHeader (real date) │  ← white card
///   │  CalendarSection (month)    │
///   └─────────────────────────────┘
///   ┌─────────────────────────────┐
///   │  Medication + Appointment   │  ← scrollable list for selected day
///   │  list for selected date     │
///   └─────────────────────────────┘
///
/// Data flow:
///   CalendarSection.onDaySelected
///     → ScheduleCubit.loadForDate(date)
///       → BlocBuilder rebuilds the list section
class PatientScheduleScreen extends StatelessWidget {
  const PatientScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(LocaleKeys.schedule_title.tr()),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: BlocBuilder<ScheduleCubit, ScheduleState>(
        builder: (context, state) {
          final cubit = context.read<ScheduleCubit>();
          final selectedDate = state is ScheduleLoaded
              ? state.selectedDate
              : DateTime.now();

          return Column(
            children: [
              // ── Top white card: header + full-month calendar ──
              Container(
                margin: EdgeInsets.symmetric(
                    horizontal: 16.w, vertical: 8.h),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow
                          .withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ScheduleHeader(selectedDate: selectedDate),
                    SizedBox(height: 12.h),
                    CalendarSection(
                      selectedDay: selectedDate,
                      onDaySelected: (day) => cubit.loadForDate(day),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 8.h),

              // ── Bottom: list for selected date ──
              Expanded(
                child: _buildList(context, state, cubit),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─── List section ────────────────────────────────────────────

  Widget _buildList(
      BuildContext context, ScheduleState state, ScheduleCubit cubit) {
    final theme = Theme.of(context);

    if (state is ScheduleLoading || state is ScheduleInitial) {
      return Center(
        child: CircularProgressIndicator(color: theme.colorScheme.primary),
      );
    }

    if (state is ScheduleError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 48.sp, color: theme.colorScheme.error),
            SizedBox(height: 12.h),
            Text(state.error,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: theme.colorScheme.error, fontSize: 15.sp)),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: () => cubit.loadForDate(DateTime.now()),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (state is ScheduleLoaded) {
      final meds = state.medications;
      final apts = state.appointments;

      if (meds.isEmpty && apts.isEmpty) {
        return _emptyState(context, state.selectedDate);
      }

      return ListView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        children: [
          if (meds.isNotEmpty) ...[
            _sectionLabel(context,
                icon: Icons.medication_rounded,
                label: 'الأدوية',
                color: theme.colorScheme.primary),
            SizedBox(height: 8.h),
            ...meds.map((med) => _MedRow(
                  reminder: med,
                  onMarkTaken: () => cubit.markAsTaken(med),
                  onDelete: () => cubit.deleteMedication(med),
                )),
          ],
          if (apts.isNotEmpty) ...[
            if (meds.isNotEmpty) SizedBox(height: 16.h),
            _sectionLabel(context,
                icon: Icons.calendar_today_rounded,
                label: 'المواعيد',
                color: Colors.orange),
            SizedBox(height: 8.h),
            ...apts.map((apt) => _AptRow(appointment: apt)),
          ],
          SizedBox(height: 24.h),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _sectionLabel(BuildContext context,
      {required IconData icon,
      required String label,
      required Color color}) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16.sp),
        SizedBox(width: 6.w),
        Text(label,
            style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface)),
      ],
    );
  }

  Widget _emptyState(BuildContext context, DateTime date) {
    final isToday = _isSameDay(date, DateTime.now());
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_available_rounded,
              size: 56.sp, color: Colors.grey.shade400),
          SizedBox(height: 12.h),
          Text(
            isToday
                ? 'لا توجد أدوية أو مواعيد اليوم'
                : 'لا توجد أدوية أو مواعيد في هذا اليوم',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15.sp,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ─── Row widgets ─────────────────────────────────────────────────────────────

class _MedRow extends StatelessWidget {
  final ReminderModel reminder;
  final VoidCallback? onMarkTaken;
  final VoidCallback? onDelete;

  const _MedRow(
      {required this.reminder, this.onMarkTaken, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTaken = reminder.status == 'taken';

    return Dismissible(
      key: ValueKey('sched_${reminder.id}_${reminder.time}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.v12),
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
            color: theme.colorScheme.error,
            borderRadius: BorderRadius.circular(14.r)),
        alignment: Alignment.centerRight,
        child: Icon(Icons.delete_outline_rounded,
            color: Colors.white, size: 22.sp),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('حذف الدواء'),
                content: Text('هل تريد حذف "${reminder.name}" نهائياً؟'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('إلغاء')),
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text('حذف',
                          style: TextStyle(
                              color: theme.colorScheme.error))),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) => onDelete?.call(),
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.v12),
        padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.h16, vertical: AppSpacing.v12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
              color: theme.colorScheme.outlineVariant
                  .withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: isTaken
                    ? theme.colorScheme.surfaceContainerHighest
                    : theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                isTaken ? Icons.check_rounded : Icons.medication_rounded,
                color: isTaken ? Colors.grey : theme.colorScheme.primary,
                size: 20.sp,
              ),
            ),
            SizedBox(width: AppSpacing.h12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reminder.name,
                      style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: isTaken
                              ? Colors.grey
                              : theme.colorScheme.onSurface,
                          decoration: isTaken
                              ? TextDecoration.lineThrough
                              : null)),
                  Text('${reminder.dosage} • ${reminder.time}',
                      textDirection: ui.TextDirection.ltr,
                      style: TextStyle(
                          fontSize: 12.sp, color: Colors.grey)),
                ],
              ),
            ),
            if (!isTaken)
              GestureDetector(
                onTap: onMarkTaken,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                      color: theme.colorScheme.primary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20.r)),
                  child: Text('خذ الآن',
                      style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold)),
                ),
              )
            else
              Text('تم ✓',
                  style: TextStyle(
                      color: Colors.green,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _AptRow extends StatelessWidget {
  final Appointment appointment;
  const _AptRow({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final timeStr =
        '${appointment.dateTime.hour.toString().padLeft(2, '0')}:${appointment.dateTime.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.v12),
      padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.h16, vertical: AppSpacing.v12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14.r),
        border:
            Border.all(color: Colors.orange.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10.r)),
            child: Icon(Icons.calendar_month_rounded,
                color: Colors.orange, size: 20.sp),
          ),
          SizedBox(width: AppSpacing.h12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appointment.title,
                    style: TextStyle(
                        fontSize: 14.sp, fontWeight: FontWeight.w600)),
                if (appointment.location.isNotEmpty)
                  Text(appointment.location,
                      style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600)),
              ],
            ),
          ),
          Container(
            padding:
                EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20.r)),
            child: Text(timeStr,
                textDirection: ui.TextDirection.ltr,
                style: TextStyle(
                    color: Colors.orange,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}