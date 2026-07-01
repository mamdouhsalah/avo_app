import 'package:ai_alarm_reminder/app/core/services/hive_service.dart';
import 'package:ai_alarm_reminder/app/core/services/notification_service.dart';
import 'package:ai_alarm_reminder/app/core/services/service_models/models.dart';
import 'package:ai_alarm_reminder/app/core/utils/constance.dart';
import 'package:flutter/material.dart';

class AddMedicationPage extends StatefulWidget {
  final Medication? medication;

  const AddMedicationPage({super.key, this.medication});

  @override
  _AddMedicationPageState createState() => _AddMedicationPageState();
}

class _AddMedicationPageState extends State<AddMedicationPage> {
  final _formKey = GlobalKey<FormState>();
  final _medicationData = MedicationData();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      _medicationData.fromMedication(widget.medication!);
    }
  }

  Future<void> _addTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        _medicationData.times.add(
          '${picked.hour}:${picked.minute.toString().padLeft(2, '0')}',
        );
      });
    }
  }

  Future<void> _saveMedication() async {
    if (_formKey.currentState!.validate() &&
        (_medicationData.days.isNotEmpty ?? false)) {
      setState(() => _isLoading = true);
      _formKey.currentState!.save();
      try {
        final medication = _medicationData.toMedication();
        final box = HiveService.getMedicationBox();

        if (widget.medication != null) {
          await NotificationService.cancelMedicationNotifications(
              widget.medication!);
          await widget.medication!.delete();
        }

        await box.add(medication);
        for (var i = 0; i < _medicationData.times.length; i++) {
          await NotificationService.scheduleMedicationNotification(
            medication,
            _medicationData.times[i],
            i,
          );
        }

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.medication == null
                    ? AppStrings.medicationAdded
                    : AppStrings.medicationUpdated,
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              backgroundColor: AppColors.successColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${AppStrings.saveError}: $e',
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              backgroundColor: AppColors.errorColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
          tooltip: AppStrings.close,
        ),
        title: Text(
          widget.medication == null
              ? AppStrings.addMedication
              : AppStrings.editMedication,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 20,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _isLoading
                ? CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                  )
                : ElevatedButton(
                    onPressed: _saveMedication,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      // padding: const EdgeInsets.symmetric(
                      //     horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      shadowColor: AppColors.primaryColor.withOpacity(0.3),
                    ),
                    child: Text(
                      widget.medication == null
                          ? AppStrings.save
                          : AppStrings.update,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                label: AppStrings.medicationName,
                initialValue: _medicationData.name,
                validator: (value) =>
                    value!.isEmpty ? AppStrings.enterMedicationName : null,
                onSaved: (value) => _medicationData.name = value!,
              ),
              _buildTextField(
                label: AppStrings.dose,
                initialValue: _medicationData.dose.toString(),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return AppStrings.enterDose;
                  final dose = double.tryParse(value);
                  if (dose == null || dose <= 0) return AppStrings.invalidDose;
                  return null;
                },
                onSaved: (value) => _medicationData.dose = double.parse(value!),
              ),
              _buildUnitDropdown(),
              const SizedBox(height: 8),
              _buildSectionTitle(AppStrings.times),
              _buildTimesChips(),
              _buildAddTimeButton(),
              const SizedBox(height: 8),
              _buildSectionTitle(AppStrings.days),
              _buildDaysChips(),
              _buildTextField(
                label: AppStrings.instructions,
                initialValue: _medicationData.instructions,
                maxLines: 3,
                onSaved: (value) => _medicationData.instructions = value!,
              ),
              // const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    required void Function(String?) onSaved,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontFamily: 'Cairo',
            color: AppColors.textSecondary,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
          ),
          alignLabelWithHint: maxLines > 1,
        ),
        keyboardType: keyboardType,
        validator: validator,
        onSaved: onSaved,
        maxLines: maxLines,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        style:
            const TextStyle(fontFamily: 'Cairo', color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildUnitDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: AppStrings.unit,
          labelStyle: const TextStyle(
            fontFamily: 'Cairo',
            color: AppColors.textSecondary,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
          ),
        ),
        initialValue: _medicationData.unit,
        items: AppConstants.units
            .map((unit) => DropdownMenuItem(
                  value: unit,
                  child:
                      Text(unit, style: const TextStyle(fontFamily: 'Cairo')),
                ))
            .toList(),
        onChanged: (value) => setState(() => _medicationData.unit = value!),
        style:
            const TextStyle(fontFamily: 'Cairo', color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildTimesChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _medicationData.times.map((time) {
        return AnimatedScaleChip(
          label: time,
          onDeleted: () => setState(() => _medicationData.times.remove(time)),
        );
      }).toList(),
    );
  }

  Widget _buildAddTimeButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton.icon(
        onPressed: _addTime,
        icon: const Icon(
          Icons.access_time,
          size: 20,
          color: Colors.white,
        ),
        label: Text(
          AppStrings.addTime,
          style: const TextStyle(
              fontFamily: 'Cairo', fontWeight: FontWeight.w500, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: AppColors.primaryColor.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildDaysChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AppConstants.availableDays.map((day) {
        return AnimatedFilterChip(
          label: day,
          selected: _medicationData.days.contains(day),
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _medicationData.days.add(day);
              } else {
                _medicationData.days.remove(day);
              }
            });
          },
        );
      }).toList(),
    );
  }
}

// Helper class to manage form data
class MedicationData {
  String name = '';
  double dose = 0;
  String unit = 'ملغ';
  List<String> times = [];
  List<String> days = [];
  String instructions = '';

  void fromMedication(Medication medication) {
    name = medication.name;
    dose = medication.dose.toDouble();
    unit = medication.unit;
    times = List.from(medication.times);
    days = List.from(medication.days);
    instructions = medication.instructions;
  }

  Medication toMedication() {
    return Medication(
      name: name,
      dose: dose,
      unit: unit,
      times: times,
      days: days,
      instructions: instructions,
    );
  }
}

// Custom chip with animation
class AnimatedScaleChip extends StatefulWidget {
  final String label;
  final VoidCallback onDeleted;

  const AnimatedScaleChip(
      {super.key, required this.label, required this.onDeleted});

  @override
  _AnimatedScaleChipState createState() => _AnimatedScaleChipState();
}

class _AnimatedScaleChipState extends State<AnimatedScaleChip> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Chip(
          label: Text(
            widget.label,
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.borderColor),
          ),
          deleteIcon: const Icon(Icons.cancel,
              size: 18, color: AppColors.textSecondary),
          onDeleted: widget.onDeleted,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
        ),
      ),
    );
  }
}

// Custom filter chip with animation
class AnimatedFilterChip extends StatefulWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const AnimatedFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  _AnimatedFilterChipState createState() => _AnimatedFilterChipState();
}

class _AnimatedFilterChipState extends State<AnimatedFilterChip> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onSelected(!widget.selected);
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: FilterChip(
          label: Text(
            widget.label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: widget.selected ? Colors.white : AppColors.textPrimary,
            ),
          ),
          selected: widget.selected,
          onSelected: widget.onSelected,
          backgroundColor: Colors.white,
          selectedColor: AppColors.primaryColor,
          checkmarkColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.borderColor),
          ),
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
        ),
      ),
    );
  }
}

// Constants and strings for localization
class AppStrings {
  static const close = 'إغلاق';
  static const addMedication = 'إضافة دواء';
  static const editMedication = 'تعديل دواء';
  static const save = 'حفظ';
  static const update = 'تعديل';
  static const medicationName = 'اسم الدواء';
  static const enterMedicationName = 'يرجى إدخال اسم الدواء';
  static const dose = 'الجرعة';
  static const enterDose = 'يرجى إدخال الجرعة';
  static const invalidDose = 'الجرعة غير صالحة';
  static const unit = 'الوحدة';
  static const times = 'الأوقات';
  static const addTime = 'إضافة وقت';
  static const days = 'الأيام';
  static const instructions = 'التعليمات';
  static const medicationAdded = 'تم إضافة الدواء بنجاح';
  static const medicationUpdated = 'تم تعديل الدواء بنجاح';
  static const saveError = 'خطأ أثناء الحفظ';
}

class AppConstants {
  static const units = ['ملغ', 'مل', 'قرص', 'كبسولة'];
  static const availableDays = [
    'السبت',
    'الأحد',
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة'
  ];
}
