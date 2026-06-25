import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;

import 'package:avo_app/app/features/profile/logic/profile_cubit.dart';
import 'package:avo_app/app/features/profile/logic/profile_state.dart';
import '../../../core/Language/locale_keys.g.dart'; // 🔥 الـ LocaleKeys

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  bool isEditMode = false;

  final TextEditingController _heightController =
      TextEditingController(text: '179.50');
  final TextEditingController _weightController =
      TextEditingController(text: '120.50');
  final TextEditingController _dobController =
      TextEditingController(text: '11 / 05 / 2006');
  
  // حقول الـ main اللي مش مربوطة بالـ Cubit
  final TextEditingController _bloodTypeController =
      TextEditingController(text: 'O+');
  final TextEditingController _chronicController =
      TextEditingController(text: 'Chronic Diseases');

  String selectedGender = 'Male';

  static const Color maleBlue = Color(0xFF00A3FF);
  static const Color femalePink = Color(0xFFFD778D);

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _dobController.dispose();
    _bloodTypeController.dispose();
    _chronicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Transform.flip(
            flipX: context.locale.languageCode == 'ar',
            child: Icon(
              Icons.arrow_back,
              color: theme.iconTheme.color,
            ),
          ),
        ),
        title: Text(
          LocaleKeys.personal_info_title.tr(),
          style:
              theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          } else if (state is ProfileSuccess && isEditMode) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(LocaleKeys.personal_info_update_success.tr()),
                backgroundColor: Colors.green,
              ),
            );
            setState(() {
              isEditMode = false;
            });
          }
        },
        builder: (context, state) {
          final cubit = context.read<ProfileCubit>();

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(LocaleKeys.personal_info_gender.tr(),
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        _buildGenderCard(
                            context,
                            LocaleKeys.personal_info_malee.tr(),
                            Icons.person,
                            maleBlue,
                            cubit.selectedGender == 'Male' ||
                                cubit.selectedGender == 'ذكر',
                            cubit,
                            'Male'),
                        const SizedBox(width: 20),
                        _buildGenderCard(
                            context,
                            LocaleKeys.personal_info_femalee.tr(),
                            Icons.person_3,
                            femalePink,
                            cubit.selectedGender == 'Female' ||
                                cubit.selectedGender == 'أنثى',
                            cubit,
                            'Female'),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        Expanded(
                            child: _buildEditableField(
                                context,
                                LocaleKeys.personal_info_height.tr(),
                                cubit.heightController,
                                isNumeric: true,
                                showEditIcon: false,
                                textDirection: ui.TextDirection.ltr)),
                        const SizedBox(width: 15),
                        Expanded(
                            child: _buildEditableField(
                                context,
                                LocaleKeys.personal_info_weight.tr(),
                                cubit.weightController,
                                isNumeric: true,
                                showEditIcon: false,
                                textDirection: ui.TextDirection.ltr)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildEditableField(
                        context, LocaleKeys.personal_info_dob.tr(), cubit.dobController,
                        isDropdown: true,
                        textDirection: ui.TextDirection.ltr,
                        onTap: () {
                          // تأكد إن الميثود دي موجودة عندك تحت
                          // _selectDateOfBirth(context, cubit);
                        }),
                    
                    // 🔥 رجعنا الحقول الخاصة ببرانش الـ main
                    const SizedBox(height: 20),
                    _buildEditableField(context, 'Blood Type', _bloodTypeController,
                        isDropdown: true),
                    const SizedBox(height: 25),
                    Text('Chronic Diseases',
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    _buildEditableField(context, '', _chronicController,
                        isDropdown: true, isHint: true),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Surgical History',
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: Icon(Icons.add,
                              color: isEditMode
                                  ? theme.iconTheme.color
                                  : theme.disabledColor),
                          onPressed: isEditMode ? () {} : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // _buildSurgicalHistoryItem(context, 'Bidding process', '08/10/2026'),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          return Container(
            padding: const EdgeInsets.all(20),
            color: theme.scaffoldBackgroundColor,
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  if (isEditMode) {
                    context.read<ProfileCubit>().updateProfile();
                  } else {
                    setState(() {
                      isEditMode = true;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEditMode
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  isEditMode
                      ? LocaleKeys.general_save.tr()
                      : LocaleKeys.general_edit.tr(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isEditMode
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGenderCard(BuildContext context, String title, IconData icon,
      Color color, bool isSelected, ProfileCubit cubit, String value) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: isEditMode
            ? () => setState(() => cubit.selectedGender = value)
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            border: Border.all(
                color: isSelected ? color : theme.dividerColor, width: 1.5),
            borderRadius: BorderRadius.circular(15),
            color: isEditMode || isSelected
                ? theme.cardColor
                : theme.scaffoldBackgroundColor,
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 55, color: isSelected ? color : theme.disabledColor),
              const SizedBox(height: 12),
              Text(title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color:
                        isSelected ? color : theme.textTheme.bodyMedium?.color,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField(
      BuildContext context, String label, TextEditingController controller,
      {bool isNumeric = false,
      bool isDropdown = false,
      bool isHint = false,
      bool showEditIcon = true,
      ui.TextDirection? textDirection,
      VoidCallback? onTap}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Text(label,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
        if (label.isNotEmpty) const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: isEditMode,
          textDirection: textDirection ?? ui.TextDirection.ltr, // 💡 ربطناها بالـ Parameter
          style: theme.textTheme.bodyMedium,
          keyboardType: isNumeric
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          readOnly: isDropdown,
          onTap: onTap, // 💡 ضفنا الـ onTap اللي كانت ناقصة هنا
          decoration: InputDecoration(
            suffixIcon: isEditMode && showEditIcon
                ? Icon(
                    isDropdown
                        ? Icons.keyboard_arrow_down
                        : Icons.edit_outlined,
                    size: 20,
                    color: theme.iconTheme.color)
                : null,
            filled: true,
            fillColor: isEditMode
                ? theme.cardColor
                : theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.3),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: isDropdown && isHint
                      ? theme.dividerColor
                      : theme.colorScheme.primary.withValues(alpha: 0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: theme.colorScheme.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}