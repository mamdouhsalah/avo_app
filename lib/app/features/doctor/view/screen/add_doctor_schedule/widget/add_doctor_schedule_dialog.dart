import 'package:avo_app/app/core/Language/locale_keys.g.dart';
import 'package:avo_app/app/core/shared/custom_text_form_field.dart';
import 'package:avo_app/app/core/shared/main_button.dart';
import 'package:avo_app/app/features/doctor/services/add_doctor_cubit/add_doctor_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddDoctorScheduleDialog extends StatefulWidget {
  const AddDoctorScheduleDialog({super.key});

  @override
  State<AddDoctorScheduleDialog> createState() =>
      _AddDoctorScheduleDialogState();
}

class _AddDoctorScheduleDialogState extends State<AddDoctorScheduleDialog> {
  final _formKey = GlobalKey<FormState>();

  final Map<String, String> _daysMap = {
    'Monday': LocaleKeys.days_monday,
    'Tuesday': LocaleKeys.days_tuesday,
    'Wednesday': LocaleKeys.days_wednesday,
    'Thursday': LocaleKeys.days_thursday,
    'Friday': LocaleKeys.days_friday,
    'Saturday': LocaleKeys.days_saturday,
    'Sunday': LocaleKeys.days_sunday,
  };

  TimeOfDay? _parseTimeString(String timeStr) {
    if (timeStr.isEmpty) return null;
    try {
      final format = RegExp(r'(\d+):(\d+)\s*(AM|PM|am|pm)?');
      final match = format.firstMatch(timeStr);
      if (match != null) {
        int hour = int.parse(match.group(1)!);
        final int minute = int.parse(match.group(2)!);
        final String? period = match.group(3);

        if (period != null) {
          if (period.toLowerCase() == 'pm' && hour < 12) {
            hour += 12;
          } else if (period.toLowerCase() == 'am' && hour == 12) {
            hour = 0;
          }
        }
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (_) {}
    return null;
  }

  String _formatTimeOfDayToEnglish(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute $period";
  }

  Future<void> _selectStartTime(AddDoctorCubit cubit) async {
    final parsed = _parseTimeString(cubit.startTime);
    final picked = await showTimePicker(
      context: context,
      initialTime: parsed ?? const TimeOfDay(hour: 9, minute: 0),
      builder: (BuildContext context, Widget? child) {
        return Localizations.override(
          context: context,
          locale: const Locale('en', 'US'),
          child: child,
        );
      },
    );
    if (picked != null) {
      setState(() {
        cubit.setStartTime(_formatTimeOfDayToEnglish(picked));
      });
    }
  }

  Future<void> _selectEndTime(AddDoctorCubit cubit) async {
    final parsed = _parseTimeString(cubit.endTime);
    final picked = await showTimePicker(
      context: context,
      initialTime: parsed ?? const TimeOfDay(hour: 17, minute: 0),
      builder: (BuildContext context, Widget? child) {
        return Localizations.override(
          context: context,
          locale: const Locale('en', 'US'),
          child: child,
        );
      },
    );
    if (picked != null) {
      setState(() {
        cubit.setEndTime(_formatTimeOfDayToEnglish(picked));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cubit = context.read<AddDoctorCubit>();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.sp),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cubit.editingIndex == null
                      ? LocaleKeys.schedule_add_title.tr()
                      : LocaleKeys.schedule_edit_title.tr(),
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 20.h),

                // Day Selection Dropdown
                Text(
                  LocaleKeys.schedule_select_day.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: cubit.selectedDay,
                      isExpanded: true,
                      dropdownColor: colorScheme.surface,
                      items: _daysMap.entries.map((entry) {
                        return DropdownMenuItem<String>(
                          value: entry.key,
                          child: Text(
                            entry.value.tr(),
                            style: TextStyle(color: colorScheme.onSurface),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            cubit.setDay(val);
                          });
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // Start Time Selection
                Text(
                  LocaleKeys.schedule_start_time.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 8.h),
                InkWell(
                  onTap: () => _selectStartTime(cubit),
                  borderRadius: BorderRadius.circular(10.r),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time,
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.5)),
                        SizedBox(width: 10.w),
                        Text(
                          cubit.startTime.isNotEmpty
                              ? cubit.startTime
                              : LocaleKeys.schedule_choose_start_time.tr(),
                          style: TextStyle(
                            color: cubit.startTime.isNotEmpty
                                ? colorScheme.onSurface
                                : colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // End Time Selection
                Text(
                  LocaleKeys.schedule_end_time.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 8.h),
                InkWell(
                  onTap: () => _selectEndTime(cubit),
                  borderRadius: BorderRadius.circular(10.r),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time_filled,
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.5)),
                        SizedBox(width: 10.w),
                        Text(
                          cubit.endTime.isNotEmpty
                              ? cubit.endTime
                              : LocaleKeys.schedule_choose_end_time.tr(),
                          style: TextStyle(
                            color: cubit.endTime.isNotEmpty
                                ? colorScheme.onSurface
                                : colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // Max Visits Input
                CustomTextFormField(
                  controller: cubit.maxVisitsController,
                  labelText: LocaleKeys.schedule_max_visits.tr(),
                  hintText: LocaleKeys.schedule_max_visits_hint.tr(),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return LocaleKeys.schedule_please_enter_max_visits.tr();
                    }
                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                      return LocaleKeys.schedule_please_enter_valid_number.tr();
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24.h),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: MainButton(
                        text: LocaleKeys.general_cancel.tr(),
                        isNo: true,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: MainButton(
                        text: LocaleKeys.general_save.tr(),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            if (cubit.startTime.isEmpty ||
                                cubit.endTime.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(LocaleKeys
                                      .schedule_please_select_times
                                      .tr()),
                                ),
                              );
                              return;
                            }

                            cubit.saveScheduleSlot();
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
