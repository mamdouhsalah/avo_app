import 'package:avo_app/app/core/constants/app_spacing.dart';
import 'package:avo_app/app/features/reminder/screens/widgets/custom_analog_clock.dart';
import 'package:avo_app/app/features/reminder/screens/widgets/wave_header_painter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui' as ui;

import '../../../core/Language/locale_keys.g.dart';
import '../logic/add_medication_cubit.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  // 🔥 إضافة الكونترولر لاسم الدواء
  final TextEditingController _nameController = TextEditingController();

  TimeOfDay selectedTime = const TimeOfDay(hour: 2, minute: 0);
  bool isSelectingHour = true;

  bool soundNotification = true;
  bool smartReminder = false;
  String selectedFrequency = 'Daily';
  DateTime? customDate;
  DateTime? fromDate;
  DateTime? toDate;

  @override
  void dispose() {
    _nameController.dispose(); // 🔥 تنظيف الكونترولر لتجنب تسريب الذاكرة
    super.dispose();
  }

  void _setAMPM(bool isPM) {
    int h = selectedTime.hour;
    if (isPM && h < 12) {
      setState(() => selectedTime = TimeOfDay(hour: h + 12, minute: selectedTime.minute));
    } else if (!isPM && h >= 12) {
      setState(() => selectedTime = TimeOfDay(hour: h - 12, minute: selectedTime.minute));
    }
  }

  Future<void> _pickDate(BuildContext context, {required Function(DateTime) onPicked}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    int displayHour = selectedTime.hourOfPeriod;
    if (displayHour == 0) displayHour = 12;
    String hourStr = displayHour.toString().padLeft(2, '0');
    String minuteStr = selectedTime.minute.toString().padLeft(2, '0');
    bool isPM = selectedTime.period == DayPeriod.pm;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0,
            child: CustomPaint(
              size: Size(double.infinity, 280.h),
              painter: WaveHeaderPainter(color: theme.colorScheme.primary.withValues(alpha: 0.15)),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.h24),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppSpacing.v12),
                  Row(
                    children: [
                      IconButton(
                        icon: Transform.flip(
                          flipX: context.locale.languageCode == 'ar', // 🔥 قلب السهم
                          child: Icon(Icons.arrow_back_ios_new_rounded, size: 20.sp),
                        ),
                        onPressed: () => context.pop(),
                      ),
                      const Spacer(),
                      Text(LocaleKeys.reminder_title.tr(), // 🔥 ترجمة العنوان
                          style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      SizedBox(width: 40.w),
                    ],
                  ),
                  SizedBox(height: AppSpacing.v32),

                  // === الساعة الرقمية التفاعلية ===
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // جزء الساعات
                      GestureDetector(
                        onTap: () => setState(() => isSelectingHour = true),
                        child: Text(
                            hourStr,
                            textDirection: ui.TextDirection.ltr,
                            style: TextStyle(
                              fontSize: 52.sp,
                              fontWeight: isSelectingHour ? FontWeight.bold : FontWeight.w300,
                              color: isSelectingHour ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                            )
                        ),
                      ),
                      Text(":", style: TextStyle(fontSize: 48.sp, fontWeight: FontWeight.w300)),
                      // جزء الدقائق
                      GestureDetector(
                        onTap: () => setState(() => isSelectingHour = false),
                        child: Text(
                            minuteStr,
                            textDirection: ui.TextDirection.ltr,
                            style: TextStyle(
                              fontSize: 52.sp,
                              fontWeight: !isSelectingHour ? FontWeight.bold : FontWeight.w300,
                              color: !isSelectingHour ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                            )
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // جزء AM / PM
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () => _setAMPM(false),
                            child: Text("am", style: TextStyle(fontSize: 16.sp, fontWeight: !isPM ? FontWeight.bold : FontWeight.normal, color: !isPM ? theme.colorScheme.primary : Colors.grey)),
                          ),
                          SizedBox(height: 4.h),
                          GestureDetector(
                            onTap: () => _setAMPM(true),
                            child: Text("pm", style: TextStyle(fontSize: 16.sp, fontWeight: isPM ? FontWeight.bold : FontWeight.normal, color: isPM ? theme.colorScheme.primary : Colors.grey)),
                          ),
                        ],
                      ),
                      const Spacer(),

                      // 🔥 زرار الإضافة مربوط بالـ Cubit
                      BlocConsumer<AddMedicationCubit, AddMedicationState>(
                        listener: (context, state) {
                          if (state is AddMedicationSuccess) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تم إضافة الدواء وجدولة التذكير بنجاح!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            context.pop(); // يرجع للشاشة السابقة بعد النجاح
                          } else if (state is AddMedicationError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.error),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        builder: (context, state) {
                          if (state is AddMedicationLoading) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          return ElevatedButton(
                            onPressed: () {
                              if (_nameController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('الرجاء إدخال اسم الدواء')),
                                );
                                return;
                              }
                              // إرسال البيانات للـ Cubit
                              context.read<AddMedicationCubit>().addMedication(
                                name: _nameController.text.trim(),
                                time: selectedTime,
                                fromDate: fromDate,
                                toDate: toDate,
                                frequency: selectedFrequency,
                                soundEnabled: soundNotification,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                              minimumSize: Size.zero,
                            ),
                            child: Text(LocaleKeys.reminder_add.tr(), // 🔥 ترجمة
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.v32),

                  Center(
                    child: InteractiveAnalogClock(
                      time: selectedTime,
                      isSelectingHour: isSelectingHour,
                      onTimeChanged: (newTime) {
                        setState(() {
                          selectedTime = newTime;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: AppSpacing.v40),

                  // 🔥 حقل إدخال اسم الدواء مربوط بالـ Controller
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: LocaleKeys.reminder_medication_name.tr(), // 🔥 ترجمة
                      prefixIcon: Icon(Icons.medication_rounded, color: theme.colorScheme.primary),
                      contentPadding: EdgeInsets.symmetric(vertical: 16.h),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: Colors.grey.shade300)),
                    ),
                  ),
                  SizedBox(height: AppSpacing.v24),

                  Row(
                    children: [
                      Expanded(child: _buildDateSection(LocaleKeys.reminder_from.tr(), fromDate, (date) => setState(() => fromDate = date))), // 🔥 ترجمة
                      SizedBox(width: AppSpacing.h24),
                      Expanded(child: _buildDateSection(LocaleKeys.reminder_to.tr(), toDate, (date) => setState(() => toDate = date))), // 🔥 ترجمة
                    ],
                  ),
                  SizedBox(height: AppSpacing.v24),

                  Text(LocaleKeys.reminder_frequency.tr(), style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700)), // 🔥 ترجمة
                  SizedBox(height: AppSpacing.v12),
                  _buildFrequencyRow(theme),
                  SizedBox(height: AppSpacing.v32),

                  Container(
                    padding: EdgeInsets.all(AppSpacing.h20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [BoxShadow(color: theme.colorScheme.shadow.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(LocaleKeys.reminder_reminder_settings.tr(), style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)), // 🔥 ترجمة
                        SizedBox(height: AppSpacing.v16),
                        _buildSwitchRow(LocaleKeys.reminder_sound_notifications.tr(), soundNotification, (val) => setState(() => soundNotification = val), theme), // 🔥
                        SizedBox(height: AppSpacing.v12),
                        _buildSwitchRow(LocaleKeys.reminder_smart_reminders.tr(), smartReminder, (val) => setState(() => smartReminder = val), theme), // 🔥
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.v40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection(String title, DateTime? selectedDate, Function(DateTime) onPicked) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 14.sp, color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
        SizedBox(height: 8.h),
        InkWell(
          onTap: () => _pickDate(context, onPicked: onPicked),
          borderRadius: BorderRadius.circular(8.r),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // 💡 إجبار الـ Row ده إنه يكون من الشمال لليمين (LTR) في الحالتين عشان التواريخ
            textDirection: ui.TextDirection.ltr,
            children: [
              _buildDateBox(selectedDate != null ? selectedDate.day.toString().padLeft(2, '0') : "DD"),
              _buildDateBox(selectedDate != null ? selectedDate.month.toString().padLeft(2, '0') : "MM"),
              _buildDateBox(selectedDate != null ? selectedDate.year.toString().substring(2) : "YY"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateBox(String text) {
    final theme = Theme.of(context);
    final bool isPlaceholder = text == "DD" || text == "MM" || text == "YY";

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      width: 45.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(
          color: isPlaceholder ? Colors.grey.shade300 : theme.colorScheme.primary.withValues(alpha: 0.5),
          width: isPlaceholder ? 1 : 1.5,
        ),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        text,
        textDirection: ui.TextDirection.ltr,
        style: TextStyle(
          color: isPlaceholder ? Colors.grey.shade400 : theme.colorScheme.primary,
          fontSize: 12.sp,
          fontWeight: isPlaceholder ? FontWeight.normal : FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFrequencyRow(ThemeData theme) {
    // 💡 بنربط الكلمة بالإنجليزي (كقيمة برمجية) مع الكلمة المترجمة للـ UI
    final Map<String, String> frequencies = {
      'Daily': LocaleKeys.reminder_daily.tr(),
      'Weekly': LocaleKeys.reminder_weekly.tr(),
      'Custom': LocaleKeys.reminder_custom.tr(),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: frequencies.entries.map((entry) {
            final freqKey = entry.key;   // ده اللي بيتسجل في الكود
            final freqValue = entry.value; // ده اللي بيتعرض للمستخدم
            final isSelected = selectedFrequency == freqKey;

            return GestureDetector(
              onTap: () {
                setState(() => selectedFrequency = freqKey);
                if (freqKey == 'Custom') {
                  _pickDate(context, onPicked: (date) => setState(() => customDate = date));
                }
              },
              child: Container(
                margin: EdgeInsetsDirectional.only(end: 12.w), // 💡 دعم الـ RTL
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  freqValue, // 🔥 الكلمة المترجمة
                  style: TextStyle(
                    color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (selectedFrequency == 'Custom') ...[
          SizedBox(height: AppSpacing.v16),
          GestureDetector(
            onTap: () => _pickDate(context, onPicked: (date) => setState(() => customDate = date)),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_month_rounded, color: theme.colorScheme.primary, size: 20.sp),
                  SizedBox(width: 12.w),
                  Text(
                    customDate == null
                        ? LocaleKeys.reminder_select_custom_date.tr() // 🔥 ترجمة
                        : LocaleKeys.reminder_selected_date.tr(namedArgs: {'date': '${customDate!.day}/${customDate!.month}/${customDate!.year}'}), // 🔥 ترجمة مع التاريخ
                    textDirection: ui.TextDirection.ltr,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSwitchRow(String title, bool value, Function(bool) onChanged, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700)),
        CupertinoSwitch(
          value: value,
          activeTrackColor: theme.colorScheme.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }
}