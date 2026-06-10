import 'dart:io';
import 'package:avo_app/app/core/Language/locale_keys.g.dart';
import 'package:avo_app/app/core/shared/custom_text_form_field.dart';
import 'package:avo_app/app/features/auth/logic/auth_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class PersonalInfoCreateAccountSection extends StatefulWidget {
  final AuthCubit cubit;

  const PersonalInfoCreateAccountSection({super.key, required this.cubit});

  @override
  State<PersonalInfoCreateAccountSection> createState() =>
      _PersonalInfoCreateAccountSectionState();
}

class _PersonalInfoCreateAccountSectionState
    extends State<PersonalInfoCreateAccountSection> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        widget.cubit.profileImagePath = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 50.r,
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                  backgroundImage: widget.cubit.profileImagePath != null
                      ? FileImage(File(widget.cubit.profileImagePath!))
                      : null,
                  child: widget.cubit.profileImagePath == null
                      ? Icon(
                          Icons.person,
                          size: 50.sp,
                          color: colorScheme.primary.withValues(alpha: 0.4),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 4.w,
                  child: CircleAvatar(
                    radius: 16.r,
                    backgroundColor: colorScheme.primary,
                    child: Icon(
                      Icons.camera_alt_outlined,
                      size: 16.sp,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // Full Name
          CustomTextFormField(
            controller: widget.cubit.fullNameController,
            labelText: LocaleKeys.auth_full_name.tr(),
            hintText: LocaleKeys.auth_full_name_hint.tr(),
            prefixIcon: const Icon(Icons.person_outline),
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
          ),
          SizedBox(height: 16.h),

          // Email Address
          CustomTextFormField(
            controller: widget.cubit.emailController,
            labelText: LocaleKeys.auth_email.tr(),
            hintText: LocaleKeys.auth_email_hint.tr(),
            prefixIcon: const Icon(Icons.email_outlined),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          SizedBox(height: 16.h),

          // Phone Number
          CustomTextFormField(
            controller: widget.cubit.phoneController,
            labelText: LocaleKeys.auth_phone.tr(),
            hintText: LocaleKeys.auth_phone_hint.tr(),
            prefixIcon: const Icon(Icons.phone_outlined),
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
          ),
          SizedBox(height: 16.h),
        ],
      );
  }
}
