import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:avo_app/app/core/Language/locale_keys.g.dart';
import 'package:avo_app/app/core/constants/app_spacing.dart';
import 'package:avo_app/app/core/routing/app_router.dart';
import 'package:avo_app/app/core/shared/main_button.dart';
import 'package:avo_app/app/features/auth/logic/auth_cubit.dart';
import 'package:avo_app/app/features/auth/logic/auth_state.dart';
import 'package:avo_app/app/features/auth/screens/widgets/contact_create_account_section.dart';
import 'package:avo_app/app/features/auth/screens/widgets/header_auth_section.dart';
import 'package:avo_app/app/features/auth/screens/widgets/personal_info_create_account_section.dart';
import 'package:avo_app/app/features/auth/screens/widgets/physical_create_account_section.dart';
import 'package:avo_app/app/features/auth/screens/widgets/role_create_account_section.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class CreateAccountTypeScreen extends StatelessWidget {
  const CreateAccountTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cubit = context.read<AuthCubit>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            if (cubit.currentStep > 0) {
              cubit.previousStep();
            } else {
              context.pop();
            }
          },
        ),
        title: Text(LocaleKeys.auth_create_account.tr()),
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
            } else if (state is AuthNeedVerification) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(LocaleKeys.auth_error_need_verification.tr()),
                  backgroundColor: colorScheme.error,
                ),
              );
              context.pushReplacement(AppRouter.login);
            } else if (state is AuthSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(LocaleKeys.shared_done.tr()),
                  backgroundColor: colorScheme.primary,
                ),
              );
              if (state.response.role == "patient") {
                context.pushReplacement(AppRouter.home);
              } else if (state.response.role == "doctor") {
                context.pushReplacement(AppRouter.dashboard);
              } else if (state.response.role == "radiology_specialist") {
                // TODO when radiologist exist
              } else if (state.response.role == "pharmacy_specialist") {
                // TODO when pharmacy exist
              } else if (state.response.role == "laboratory_specialist") {
                // TODO when laboratory exist
              } else {
                // TODO when any other role
              }
            }
          },
          builder: (context, state) {
            final currentStep = cubit.currentStep;

            String subtitleKey = currentStep == 0
                ? LocaleKeys.auth_choose_role
                : LocaleKeys.auth_create_desc;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.h24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HeaderAuthSection(
                            title: LocaleKeys.auth_create_account.tr(),
                            subtitle: subtitleKey.tr(),
                          ),
                          SizedBox(height: 16.h),
                          Center(
                            child: SizedBox(
                              width: 280.w,
                              child: AnimatedToggleSwitch<int>.rolling(
                                current: currentStep,
                                values: const [0, 1, 2, 3],
                                onChanged: (step) {
                                  if (step < currentStep) {
                                    cubit.setStep(step);
                                  } else {
                                    bool valid = true;
                                    int startStep = currentStep;
                                    while (startStep < step) {
                                      cubit.currentStep = startStep;
                                      final err = cubit.validateCurrentStep();
                                      if (err != null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(err.tr()),
                                            backgroundColor: colorScheme.error,
                                          ),
                                        );
                                        valid = false;
                                        break;
                                      }
                                      startStep++;
                                    }
                                    if (valid) {
                                      cubit.setStep(step);
                                    } else {
                                      cubit.setStep(startStep);
                                    }
                                  }
                                },
                                iconBuilder: (value, size) {
                                  final isDone = currentStep > value;
                                  final isCurrent = currentStep == value;
                                  return isDone
                                      ? Icon(Icons.check,
                                          size: 18.sp,
                                          color: colorScheme.primary)
                                      : Text(
                                          '${value + 1}',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.bold,
                                            color: isCurrent
                                                ? colorScheme.onPrimary
                                                : colorScheme.onSurface
                                                    .withValues(alpha: 0.5),
                                          ),
                                        );
                                },
                                style: ToggleStyle(
                                  backgroundColor: colorScheme.surface,
                                  borderColor: colorScheme.outlineVariant,
                                  indicatorColor: colorScheme.primary,
                                  borderRadius: BorderRadius.circular(24.r),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 24.h),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _buildStepContent(currentStep, cubit),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (state is AuthLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: Center(
                        child: MainButton(
                          text: (currentStep == 3
                                  ? LocaleKeys.auth_sign_up
                                  : LocaleKeys.auth_continue)
                              .tr(),
                          onPressed: () {
                            if (currentStep == 3) {
                              cubit.register();
                            } else {
                              cubit.nextStep();
                            }
                          },
                        ),
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

  Widget _buildStepContent(int step, AuthCubit cubit) {
    switch (step) {
      case 0:
        return RoleCreateAccountSection(cubit: cubit);
      case 1:
        return PersonalInfoCreateAccountSection(cubit: cubit);
      case 2:
        return ContactCreateAccountSection(cubit: cubit);
      case 3:
        return PhysicalCreateAccountSection(cubit: cubit);
      default:
        return const SizedBox.shrink();
    }
  }
}
