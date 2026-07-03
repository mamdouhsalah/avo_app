import 'package:avo_app/app/core/Language/locale_keys.g.dart';
import 'package:avo_app/app/core/models/schedule_model.dart';
import 'package:avo_app/app/core/shared/error_feedback_widget.dart';
import 'package:avo_app/app/core/shared/loading_indicator_widget.dart';
import 'package:avo_app/app/core/shared/main_button.dart';
import 'package:avo_app/app/features/doctor/services/add_doctor_cubit/add_doctor_cubit.dart';
import 'package:avo_app/app/features/doctor/services/add_doctor_cubit/add_doctor_state.dart';
import 'package:avo_app/app/features/doctor/view/screen/add_doctor_schedule/widget/add_doctor_schedule_dialog.dart';
import 'package:avo_app/app/features/doctor/view/screen/add_doctor_schedule/widget/schedule_card.dart';
import 'package:avo_app/app/features/doctor/view/widget/custom_drawer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddDoctorScheduleScreen extends StatefulWidget {
  const AddDoctorScheduleScreen({super.key});

  @override
  State<AddDoctorScheduleScreen> createState() => _AddDoctorScheduleScreenState();
}

class _AddDoctorScheduleScreenState extends State<AddDoctorScheduleScreen> {
  void _openAddScheduleDialog(BuildContext context, {ScheduleModel? schedule, int? index}) {
    final cubit = context.read<AddDoctorCubit>();
    cubit.initForm(schedule: schedule, index: index);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: cubit,
          child: const AddDoctorScheduleDialog(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        drawer: const CustomDrawer(),
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
            LocaleKeys.schedule_manage_title.tr(),
            style: TextStyle(
              color: theme.textTheme.titleLarge?.color,
              fontWeight: FontWeight.bold,
              fontSize: 24.sp,
            ),
          ),
        ),
        body: BlocConsumer<AddDoctorCubit, AddDoctorState>(
          listener: (context, state) {
            if (state is AddDoctorScheduleActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: colorScheme.primary,
                ),
              );
            } else if (state is AddDoctorScheduleError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: colorScheme.error,
                ),
              );
            }
          },
          builder: (context, state) {
            final cubit = context.read<AddDoctorCubit>();
            final schedules = cubit.localSchedules;
      
            if (state is AddDoctorScheduleLoading && schedules.isEmpty) {
              return const LoadingIndicatorWidget();
            }
      
            if (state is AddDoctorScheduleError && schedules.isEmpty) {
              return ErrorFeedbackWidget(
                errorMessage: state.message,
                onRetry: () => cubit.loadSchedules(),
              );
            }
      
            return SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: schedules.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 80.sp,
                                  color: colorScheme.outlineVariant,
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  LocaleKeys.schedule_no_schedules.tr(),
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  LocaleKeys.schedule_tap_to_add.tr(),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                            itemCount: schedules.length,
                            separatorBuilder: (context, index) => SizedBox(height: 12.h),
                            itemBuilder: (context, index) {
                              final schedule = schedules[index];
                              return ScheduleCard(
                                schedule: schedule,
                                onEdit: () => _openAddScheduleDialog(context, schedule: schedule, index: index),
                                onDelete: () => cubit.deleteScheduleLocal(index),
                              );
                            },
                          ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.sp),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (state is AddDoctorScheduleLoading)
                          const LoadingIndicatorWidget(height: 48)
                        else
                          MainButton(
                            text: LocaleKeys.schedule_add_slot_btn.tr(),
                            isNo: true,
                            width: double.infinity,
                            onPressed: () => _openAddScheduleDialog(context),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
  }
}