import 'package:avo_app/app/core/Language/locale_keys.g.dart';
import 'package:avo_app/app/core/shared/custom_text_form_field.dart';
import 'package:avo_app/app/features/auth/logic/auth_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PhysicalCreateAccountSection extends StatelessWidget {
  final AuthCubit cubit;

  const PhysicalCreateAccountSection({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextFormField(
          controller: cubit.passwordController,
          labelText: LocaleKeys.auth_password.tr(),
          hintText: LocaleKeys.auth_password_hint.tr(),
          prefixIcon: const Icon(Icons.lock_outline),
          isPassword: true,
          textInputAction: TextInputAction.next,
        ),
        SizedBox(height: 16.h),
        CustomTextFormField(
          controller: cubit.confirmPasswordController,
          labelText: LocaleKeys.auth_confirm_password.tr(),
          hintText: LocaleKeys.auth_confirm_password_hint.tr(),
          prefixIcon: const Icon(Icons.lock_reset_outlined),
          isPassword: true,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }
}
