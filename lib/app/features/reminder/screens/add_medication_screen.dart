import 'package:avo_app/app/core/constants/app_spacing.dart';
import 'package:avo_app/app/features/reminder/screens/widgets/custom_analog_clock.dart'; // مسار الساعة الجديد
import 'package:avo_app/app/features/reminder/screens/widgets/wave_header_painter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  // === متغيرات الساعة التفاعلية ===
  TimeOfDay selectedTime = const TimeOfDay(hour: 2, minute: 0);
  bool isSelectingHour = true; // للتبديل بين الساعات والدقائق

  // === باقي المتغيرات ===
  bool soundNotification = true;
  bool smartReminder = false;
  String selectedFrequency = 'Daily';
  DateTime? customDate;
  DateTime? fromDate;
  DateTime? toDate;

  // دالة لتغيير AM / PM
  void _setAMPM(bool isPM) {
    int h = selectedTime.hour;
    if (isPM && h < 12) {
      setState(() => selectedTime = TimeOfDay(hour: h + 12, minute: selectedTime.minute));
    } else if (!isPM && h >= 12) {
      setState(() => selectedTime = TimeOfDay(hour: h - 12, minute: selectedTime.minute));
    }
  }

  // باقي دالة التاريخ كما هي
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

    // تظبيط شكل الساعة الرقمية عشان تظهر بصيغة 12 ساعة
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
              painter: WaveHeaderPainter(color: theme.colorScheme.primary.withOpacity(0.15)),
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
                        icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20.sp),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      Text("Reminder", style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold)),
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
                      // زر الحفظ ADD
                      ElevatedButton(
                        onPressed: () {
                          // TODO: حفظ البيانات في قاعدة البيانات
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                          minimumSize: Size.zero,
                        ),
                        child: const Text("ADD", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.v32),

                  // === دايرة الساعة التفاعلية ===
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

                  // باقي الواجهة (الاسم، التواريخ، التردد، الإعدادات)
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Medication Name",
                      prefixIcon: Icon(Icons.medication_rounded, color: theme.colorScheme.primary),
                      contentPadding: EdgeInsets.symmetric(vertical: 16.h),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: Colors.grey.shade300)),
                    ),
                  ),
                  SizedBox(height: AppSpacing.v24),

                  Row(
                    children: [
                      Expanded(child: _buildDateSection("From", fromDate, (date) => setState(() => fromDate = date))),
                      SizedBox(width: AppSpacing.h24),
                      Expanded(child: _buildDateSection("To", toDate, (date) => setState(() => toDate = date))),
                    ],
                  ),
                  SizedBox(height: AppSpacing.v24),

                  Text("Frequency", style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700)),
                  SizedBox(height: AppSpacing.v12),
                  _buildFrequencyRow(theme),
                  SizedBox(height: AppSpacing.v32),

                  Container(
                    padding: EdgeInsets.all(AppSpacing.h20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [BoxShadow(color: theme.colorScheme.shadow.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Reminder Settings", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                        SizedBox(height: AppSpacing.v16),
                        _buildSwitchRow("Sound notifications", soundNotification, (val) => setState(() => soundNotification = val), theme),
                        SizedBox(height: AppSpacing.v12),
                        _buildSwitchRow("Smart reminders", smartReminder, (val) => setState(() => smartReminder = val), theme),
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

  // === ويدجت مساعدة: قسم التاريخ (DD MM YY) ===
  Widget _buildDateSection(String title, DateTime? selectedDate, Function(DateTime) onPicked) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 14.sp, color: theme.colorScheme.onSurface.withOpacity(0.7))),
        SizedBox(height: 8.h),
        InkWell(
          onTap: () => _pickDate(context, onPicked: onPicked),
          borderRadius: BorderRadius.circular(8.r),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

  // === ويدجت مساعدة: المربع الصغير للتاريخ ===
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
          color: isPlaceholder ? Colors.grey.shade300 : theme.colorScheme.primary.withOpacity(0.5),
          width: isPlaceholder ? 1 : 1.5,
        ),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isPlaceholder ? Colors.grey.shade400 : theme.colorScheme.primary,
          fontSize: 12.sp,
          fontWeight: isPlaceholder ? FontWeight.normal : FontWeight.bold,
        ),
      ),
    );
  }

  // === ويدجت مساعدة: صف التردد (Frequency) ===
  Widget _buildFrequencyRow(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: ['Daily', 'Weekly', 'Custom'].map((freq) {
            final isSelected = selectedFrequency == freq;
            return GestureDetector(
              onTap: () {
                setState(() => selectedFrequency = freq);
                if (freq == 'Custom') {
                  _pickDate(context, onPicked: (date) => setState(() => customDate = date));
                }
              },
              child: Container(
                margin: EdgeInsets.only(right: 12.w),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  freq,
                  style: TextStyle(
                    color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        // كارت الـ Custom Date بيظهر بس لو اختار Custom
        if (selectedFrequency == 'Custom') ...[
          SizedBox(height: AppSpacing.v16),
          GestureDetector(
            onTap: () => _pickDate(context, onPicked: (date) => setState(() => customDate = date)),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_month_rounded, color: theme.colorScheme.primary, size: 20.sp),
                  SizedBox(width: 12.w),
                  Text(
                    customDate == null
                        ? "Select Custom Date"
                        : "Selected Date: ${customDate!.day}/${customDate!.month}/${customDate!.year}",
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

  // === ويدجت مساعدة: صف الـ Switch ===
  Widget _buildSwitchRow(String title, bool value, Function(bool) onChanged, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700)),
        CupertinoSwitch(
          value: value,
          activeColor: theme.colorScheme.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }
}