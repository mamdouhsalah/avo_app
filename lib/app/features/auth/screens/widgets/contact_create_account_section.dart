import 'package:avo_app/app/core/Language/locale_keys.g.dart';
import 'package:avo_app/app/core/shared/custom_text_form_field.dart';
import 'package:avo_app/app/features/auth/logic/auth_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ContactCreateAccountSection extends StatefulWidget {
  final AuthCubit cubit;

  const ContactCreateAccountSection({super.key, required this.cubit});

  @override
  State<ContactCreateAccountSection> createState() =>
      _ContactCreateAccountSectionState();
}

class _ContactCreateAccountSectionState
    extends State<ContactCreateAccountSection> {
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.cubit.selectedDob ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        widget.cubit.selectedDob = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.auth_gender.tr(),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    widget.cubit.selectedGender = 'male';
                  });
                },
                child: Container(
                  height: 110.h,
                  decoration: BoxDecoration(
                    color: widget.cubit.selectedGender == 'male'
                        ? colorScheme.primary.withValues(alpha: 0.05)
                        : colorScheme.surface,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: widget.cubit.selectedGender == 'male'
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                      width: widget.cubit.selectedGender == 'male' ? 2.w : 1.w,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.male,
                        size: 44.sp,
                        color: widget.cubit.selectedGender == 'male'
                            ? colorScheme.primary
                            : colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        LocaleKeys.auth_malee.tr(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: widget.cubit.selectedGender == 'male'
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    widget.cubit.selectedGender = 'female';
                  });
                },
                child: Container(
                  height: 110.h,
                  decoration: BoxDecoration(
                    color: widget.cubit.selectedGender == 'female'
                        ? colorScheme.primary.withValues(alpha: 0.05)
                        : colorScheme.surface,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: widget.cubit.selectedGender == 'female'
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                      width:
                          widget.cubit.selectedGender == 'female' ? 2.w : 1.w,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.female,
                        size: 44.sp,
                        color: widget.cubit.selectedGender == 'female'
                            ? colorScheme.primary
                            : colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        LocaleKeys.auth_femalee.tr(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: widget.cubit.selectedGender == 'female'
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),
        if (widget.cubit.selectedRole != 'doctor') ...[
          Row(
            children: [
              Expanded(
                child: CustomTextFormField(
                  controller: widget.cubit.heightController,
                  labelText: LocaleKeys.auth_height.tr(),
                  hintText: LocaleKeys.auth_height_hint.tr(),
                  prefixIcon: const Icon(Icons.height_outlined),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: CustomTextFormField(
                  controller: widget.cubit.weightController,
                  labelText: LocaleKeys.auth_weight.tr(),
                  hintText: LocaleKeys.auth_weight_hint.tr(),
                  prefixIcon: const Icon(Icons.monitor_weight_outlined),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
        ] else ...[
          CustomTextFormField(
            controller: widget.cubit.locationController,
            labelText: LocaleKeys.auth_location.tr(),
            hintText: LocaleKeys.auth_location_hint.tr(),
            prefixIcon: const Icon(Icons.location_on_outlined),
            textInputAction: TextInputAction.next,
          ),
          SizedBox(height: 20.h),
          CustomTextFormField(
            controller: widget.cubit.priceController,
            labelText: LocaleKeys.auth_price.tr(),
            hintText: LocaleKeys.auth_price_hint.tr(),
            prefixIcon: const Icon(Icons.attach_money_outlined),
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
          ),
          SizedBox(height: 20.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocaleKeys.auth_specialty.tr(),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 8.h),
              DropdownButtonFormField<String>(
                initialValue: widget.cubit.selectedSpecialty,
                hint: Text(
                  LocaleKeys.auth_specialty_hint.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                decoration: InputDecoration(
                  prefixIcon: IconTheme(
                    data: IconThemeData(
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                      size: 20.sp,
                    ),
                    child: const Icon(Icons.stars_outlined),
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(
                      color: colorScheme.outlineVariant,
                      width: 1.w,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(
                      color: colorScheme.outlineVariant,
                      width: 1.w,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 1.w,
                    ),
                  ),
                ),
                items: [
                  'cardiologist',
                  'neurosurgeon',
                  'orthopedic',
                  'pediatrician',
                  'dermatologist',
                  'gynecologist',
                  'dentist',
                  'ent',
                  'ophthalmologist',
                  'general_practitioner',
                ].map((spec) {
                  String transKey = 'auth.specialties.$spec';
                  return DropdownMenuItem<String>(
                    value: spec,
                    child: Text(
                      transKey.tr(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    widget.cubit.selectedSpecialty = val;
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 20.h),
        ],
        Text(
          LocaleKeys.auth_dob.tr(),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        InkWell(
          onTap: () => _selectDate(context),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: colorScheme.outlineVariant,
                width: 1.w,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.cubit.selectedDob == null
                      ? LocaleKeys.auth_dob_hint.tr()
                      : DateFormat('dd / MM / yyyy')
                          .format(widget.cubit.selectedDob!),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: widget.cubit.selectedDob == null
                        ? colorScheme.onSurface.withValues(alpha: 0.5)
                        : colorScheme.onSurface,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }
}
