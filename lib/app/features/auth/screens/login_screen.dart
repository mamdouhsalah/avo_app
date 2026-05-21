import 'package:avo_app/app/core/routing/app_router.dart';
import 'package:avo_app/app/core/constants/app_imgs.dart';
import 'package:avo_app/app/core/constants/app_spacing.dart';
import 'package:avo_app/app/core/shared/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.h24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  AppImgs.logo,
                  height: 80.h,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 40.h),
              Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Sign in to continue',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              SizedBox(height: 32.h),
              Container(
                height: 50.h,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  labelPadding: EdgeInsets.symmetric(horizontal: 16.w),
                  indicator: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor:
                      colorScheme.onSurface.withValues(alpha: 0.6),
                  labelStyle:
                      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Patient'),
                    Tab(text: 'Doctor'),
                    Tab(text: 'Pharmacy'),
                    Tab(text: 'Hospital'),
                    Tab(text: 'Store'),
                    Tab(text: 'Sharity'),
                    Tab(text: 'Admin'),
                  ],
                ),
              ),
              SizedBox(height: 32.h),
              const CustomTextFormField(
                labelText: 'Email Address',
                hintText: 'Enter your email',
                prefixIcon: Icon(Icons.email_outlined),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16.h),
              const CustomTextFormField(
                labelText: 'Password',
                hintText: 'Enter your password',
                prefixIcon: Icon(Icons.lock_outline),
                isPassword: true,
                textInputAction: TextInputAction.done,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    context.push(AppRouter.resetPassword);
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Login'),
              ),
              SizedBox(height: 32.h),
              Row(
                children: [
                  Expanded(
                      child: Divider(
                          color: colorScheme.outlineVariant, thickness: 1)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      'Or continue with',
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
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _SocialButton(icon: AppImgs.google, onTap: () {}),
                  _SocialButton(icon: AppImgs.facebook, onTap: () {}),
                  _SocialButton(icon: AppImgs.apple, onTap: () {}),
                ],
              ),
              SizedBox(height: 32.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "New to AVO? ",
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
                      'Create an account',
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
        width: 80.w,
        height: 56.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Center(
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
      ),
    );
  }
}
