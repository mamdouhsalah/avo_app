import 'package:avo_app/app/core/Language/locale_keys.g.dart';
import 'package:avo_app/app/core/routing/app_router.dart';
import 'package:avo_app/app/core/constants/app_imgs.dart';
import 'package:avo_app/app/core/constants/app_spacing.dart';
import 'package:avo_app/app/core/shared/custom_text_form_field.dart';
import 'package:avo_app/app/core/shared/main_button.dart';
import 'package:avo_app/app/features/auth/logic/auth_cubit.dart';
import 'package:avo_app/app/features/auth/logic/auth_state.dart';
import 'package:avo_app/app/features/auth/screens/widgets/header_auth_section.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cubit = context.read<AuthCubit>();

    return Scaffold(
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
            } else if (state is AuthSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(LocaleKeys.shared_done.tr()),
                  backgroundColor: colorScheme.primary,
                ),
              );
              context.pushReplacement(AppRouter.home);
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.h16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeaderAuthSection(
                    title: LocaleKeys.auth_welcome_back.tr(),
                    subtitle: LocaleKeys.auth_sign_in_desc.tr(),
                  ),
                  SizedBox(height: 32.h),

                  // Email Input
                  CustomTextFormField(
                    controller: cubit.emailController,
                    labelText: LocaleKeys.auth_email.tr(),
                    hintText: LocaleKeys.auth_email_hint.tr(),
                    prefixIcon: const Icon(Icons.email_outlined),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 16.h),

                  // Password Input
                  CustomTextFormField(
                    controller: cubit.passwordController,
                    labelText: LocaleKeys.auth_password.tr(),
                    hintText: LocaleKeys.auth_password_hint.tr(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                  ),

                  // Forgot Password Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        context.push(AppRouter.resetPassword);
                      },
                      child: Text(
                        LocaleKeys.auth_forgot_password.tr(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Submit Button
                  if (state is AuthLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Center(
                      child: MainButton(
                        text: LocaleKeys.auth_login.tr(),
                        onPressed: () {
                          cubit.login();
                        },
                      ),
                    ),
                  SizedBox(height: 32.h),

                  // Divider
                  Row(
                    children: [
                      Expanded(
                          child: Divider(
                              color: colorScheme.outlineVariant, thickness: 1)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text(
                          LocaleKeys.auth_or_continue_with.tr(),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      Expanded(
                          child: Divider(
                              color: colorScheme.outlineVariant, thickness: 1)),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  // Social Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _SocialButton(icon: AppImgs.google, onTap: () {}),
                      _SocialButton(icon: AppImgs.facebook, onTap: () {}),
                      _SocialButton(icon: AppImgs.apple, onTap: () {}),
                    ],
                  ),
                  SizedBox(height: 32.h),

                  // Navigation Link to Signup
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        LocaleKeys.auth_new_to_avo.tr(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.push(AppRouter.createAccountType);
                        },
                        child: Text(
                          LocaleKeys.auth_create_an_account.tr(),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
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

class _SocialButton extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;

  const _SocialButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: SvgPicture.asset(
          icon,
          width: 24.w,
          height: 24.h,
          placeholderBuilder: (context) => Icon(
            Icons.login,
            color: colorScheme.onSurface.withValues(alpha: 0.2),
          ),
        ),
      ),
    );
  }
}
