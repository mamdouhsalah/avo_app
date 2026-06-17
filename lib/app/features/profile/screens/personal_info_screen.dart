import 'package:avo_app/app/features/profile/logic/profile_cubit.dart';
import 'package:avo_app/app/features/profile/logic/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  bool isEditMode = false;

  static const Color maleBlue = Color(0xFF00A3FF);
  static const Color femalePink = Color(0xFFFD778D);

  Future<void> _selectDateOfBirth(
      BuildContext context, ProfileCubit cubit) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final formatted =
          "${picked.day.toString().padLeft(2, '0')} / ${picked.month.toString().padLeft(2, '0')} / ${picked.year}";
      cubit.dobController.text = formatted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Personal Information',
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
              const SnackBar(
                content: Text('Personal information updated successfully'),
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
                    Text('Gender',
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        _buildGenderCard(context, 'Male', Icons.person,
                            maleBlue, cubit.selectedGender == 'Male', cubit),
                        const SizedBox(width: 20),
                        _buildGenderCard(
                            context,
                            'Female',
                            Icons.person_3,
                            femalePink,
                            cubit.selectedGender == 'Female',
                            cubit),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        Expanded(
                            child: _buildEditableField(
                                context, 'Height (CM)', cubit.heightController,
                                isNumeric: true, showEditIcon: false)),
                        const SizedBox(width: 15),
                        Expanded(
                            child: _buildEditableField(
                                context, 'Weight (KG)', cubit.weightController,
                                isNumeric: true, showEditIcon: false)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildEditableField(
                        context, 'Date of Birth', cubit.dobController,
                        isDropdown: true,
                        onTap: () => _selectDateOfBirth(context, cubit)),
                    const SizedBox(height: 25),
                    // Text('Chronic Diseases',
                    //     style: theme.textTheme.bodyLarge
                    //         ?.copyWith(fontWeight: FontWeight.bold)),
                    // const SizedBox(height: 25),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Text('Surgical History',
                    //         style: theme.textTheme.bodyLarge
                    //             ?.copyWith(fontWeight: FontWeight.bold)),
                    //     IconButton(
                    //       icon: Icon(Icons.add,
                    //           color: isEditMode
                    //               ? theme.iconTheme.color
                    //               : theme.disabledColor),
                    //       onPressed: isEditMode ? () {} : null,
                    //     ),
                    //   ],
                    // ),
                    // const SizedBox(height: 8),
                    // _buildSurgicalHistoryItem(context, 'Bidding process', '08/10/2026'),
                    // const SizedBox(height: 100),
                  ],
                ),
              ),
              if (state is ProfileLoading)
                const Center(child: CircularProgressIndicator()),
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
                  isEditMode ? 'Save' : 'Edit',
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
      Color color, bool isSelected, ProfileCubit cubit) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: isEditMode
            ? () => setState(() => cubit.selectedGender = title)
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
          style: theme.textTheme.bodyMedium,
          keyboardType: isNumeric
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          readOnly: isDropdown,
          onTap: isEditMode && isDropdown ? onTap : null,
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

  Widget _buildSurgicalHistoryItem(
      BuildContext context, String title, String date) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
      decoration: BoxDecoration(
        border:
            Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(10),
        color: isEditMode
            ? theme.cardColor
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500)),
          Text(date,
              style:
                  theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
        ],
      ),
    );
  }
}
