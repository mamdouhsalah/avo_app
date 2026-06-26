import 'package:avo_app/app/core/routing/app_router.dart';
import 'package:avo_app/app/core/constants/app_spacing.dart';
import 'package:avo_app/app/features/reminder/screens/widgets/add_medication_fab.dart';
import 'package:avo_app/app/features/reminder/screens/widgets/next_dose_card.dart';
import 'package:avo_app/app/features/reminder/screens/widgets/schedule_tile.dart';
import 'package:avo_app/app/features/reminder/screens/widgets/wave_header_painter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/Language/locale_keys.g.dart';
import '../logic/reminder_cubit.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Load today's schedule from Hive as soon as the screen mounts
    context.read<ReminderCubit>().loadTodaysMedications();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<ReminderCubit>().loadTodaysMedications();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          // 1. Wave background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: Size(double.infinity, 300.h),
              painter: WaveHeaderPainter(color: theme.colorScheme.primary),
            ),
          ),

          // 2. Content
          SafeArea(
            child: Column(
              children: [
                // Title bar
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: AppSpacing.v16,
                      horizontal: AppSpacing.h20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 40.w), // Placeholder for balance
                      Text(
                        LocaleKeys.reminder_title.tr(),
                        style: TextStyle(
                          inherit: false,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      IconButton(
                        onPressed: () => context.push(AppRouter.adherenceReport),
                        icon: Icon(
                          Icons.analytics_rounded,
                          color: theme.colorScheme.onSurface,
                          size: 28.sp,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: BlocBuilder<ReminderCubit, ReminderState>(
                    builder: (context, state) {
                      if (state is ReminderLoading ||
                          state is ReminderInitial) {
                        return Center(
                          child: CircularProgressIndicator(
                              color: theme.colorScheme.primary),
                        );
                      }

                      if (state is ReminderError) {
                        return Center(
                          child: Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: 24.w),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.error_outline_rounded,
                                    size: 48.sp,
                                    color: theme.colorScheme.error),
                                SizedBox(height: 12.h),
                                Text(
                                  state.error,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: theme.colorScheme.error,
                                      fontSize: 16.sp),
                                ),
                                SizedBox(height: 16.h),
                                ElevatedButton.icon(
                                  onPressed: () => context
                                      .read<ReminderCubit>()
                                      .loadTodaysMedications(),
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: const Text('إعادة المحاولة'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (state is ReminderLoaded) {
                        final cubit = context.read<ReminderCubit>();
                        final schedule = state.todaysSchedule;

                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.h20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: AppSpacing.v12),

                              // ── Next Dose Card (real data) ──
                              if (state.nextDose != null)
                                NextDoseCard(
                                  nextDose: state.nextDose!,
                                  onTake: () =>
                                      cubit.markAsTaken(state.nextDose!),
                                ),

                              // ── All doses taken banner ──
                              if (state.nextDose == null &&
                                  schedule.isNotEmpty)
                                Center(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 16.h,
                                        horizontal: 20.w),
                                    decoration: BoxDecoration(
                                      color: Colors.green
                                          .withValues(alpha: 0.1),
                                      borderRadius:
                                          BorderRadius.circular(16.r),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                            Icons.celebration_rounded,
                                            color: Colors.green),
                                        SizedBox(width: 8.w),
                                        Text(
                                          'تم أخذ جميع الأدوية اليوم!',
                                          style: TextStyle(
                                              fontSize: 16.sp,
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                              SizedBox(height: AppSpacing.v32),

                              // ── Section header ──
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    LocaleKeys.reminder_todays_schedule.tr(),
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        context.push(AppRouter.schedule),
                                    child: Text(
                                      LocaleKeys.reminder_see_all.tr(),
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: AppSpacing.v16),

                              // ── Empty state ──
                              if (schedule.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 40.h),
                                    child: Column(
                                      children: [
                                        Icon(
                                            Icons.event_available_rounded,
                                            size: 60.sp,
                                            color: Colors.grey.shade400),
                                        SizedBox(height: 12.h),
                                        Text(
                                          'لا توجد أدوية مجدولة لهذا اليوم',
                                          style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 16.sp),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                // ── Real medication list ──
                                ...schedule.map((item) => ScheduleTile(
                                      reminder: item,
                                      onMarkTaken: () =>
                                          cubit.markAsTaken(item),
                                      onMarkSkipped: () =>
                                          cubit.markAsSkipped(item),
                                      onDelete: () =>
                                          cubit.deleteMedication(item),
                                    )),

                              SizedBox(height: 100.h),
                            ],
                          ),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      floatingActionButton: AddMedicationFab(
        onPressed: () async {
          await context.push(AppRouter.addMedication);
          // Reload after returning from the add screen
          if (context.mounted) {
            context.read<ReminderCubit>().loadTodaysMedications();
          }
        },
      ),
    );
  }
}