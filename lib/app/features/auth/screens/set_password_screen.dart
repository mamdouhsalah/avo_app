import 'package:avo_app/app/core/routing/app_router.dart';
import 'package:avo_app/app/core/constants/app_spacing.dart';
import 'package:avo_app/app/core/shared/custom_text_form_field.dart';
import 'package:avo_app/app/core/shared/main_button.dart';
import 'package:avo_app/app/features/auth/screens/widgets/header_auth_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class SetPasswordScreen extends StatefulWidget {
  const SetPasswordScreen({super.key});

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20.h),
            Icon(
              Icons.check_circle_outline,
              color: Theme.of(context).colorScheme.primary,
              size: 80.sp,
            ),
            SizedBox(height: 24.h),
            Text(
              'Password Reset!',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Your password has been successfully reset. You can now login with your new password.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: 32.h),
            Center(
              child: MainButton(
                text: 'Back to Login',
                onPressed: () {
                  context.go(AppRouter.login);
                },
              ),
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
        title: const Text('Create New Password'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.h24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeaderAuthSection(
                  title: "New Password",
                  subtitle:
                      "Please enter and confirm your new password to complete the reset process."),
              SizedBox(height: 32.h),
              const CustomTextFormField(
                labelText: 'New Password',
                hintText: 'Enter new password',
                prefixIcon: Icon(Icons.lock_outline),
                isPassword: true,
              ),
              SizedBox(height: 24.h),
              const CustomTextFormField(
                labelText: 'Confirm Password',
                hintText: 'Repeat new password',
                prefixIcon: Icon(Icons.lock_reset_outlined),
                isPassword: true,
                textInputAction: TextInputAction.done,
              ),
              SizedBox(height: 48.h),
              ElevatedButton(
                onPressed: _showSuccessDialog,
                child: const Text('Reset Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
