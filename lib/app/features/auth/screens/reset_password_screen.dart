import 'package:avo_app/app/core/Language/locale_keys.g.dart';
import 'package:avo_app/app/core/constants/app_spacing.dart';
import 'package:avo_app/app/core/routing/app_router.dart';
import 'package:avo_app/app/core/shared/custom_text_form_field.dart';
import 'package:avo_app/app/core/shared/main_button.dart';
import 'package:avo_app/app/features/auth/logic/auth_cubit.dart';
import 'package:avo_app/app/features/auth/logic/auth_state.dart';
import 'package:avo_app/app/features/auth/screens/widgets/header_auth_section.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cubit = context.read<AuthCubit>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
        title: Text(LocaleKeys.auth_forgot_password_appbar.tr()),
      ),
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error.tr()),
                  backgroundColor: colorScheme.error,
                ),
              );
            } else if (state is AuthResetPasswordSuccessfully) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(LocaleKeys.auth_reset_email_sent.tr()),
                  backgroundColor: colorScheme.primary,
                ),
              );
              context.go(AppRouter.login);
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.h24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeaderAuthSection(
                    title: LocaleKeys.auth_forgot_password_title.tr(),
                    subtitle: LocaleKeys.auth_forgot_password_subtitle.tr(),
                  ),
                  SizedBox(height: 32.h),
                  CustomTextFormField(
                    controller: cubit.emailController,
                    labelText: LocaleKeys.auth_email.tr(),
                    hintText: LocaleKeys.auth_email_hint.tr(),
                    prefixIcon: const Icon(Icons.email_outlined),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                  ),
                  SizedBox(height: 40.h),
                  if (state is AuthLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Center(
                      child: MainButton(
                        text: LocaleKeys.auth_send_code.tr(),
                        onPressed: () {
                          cubit.resetPassword();
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
