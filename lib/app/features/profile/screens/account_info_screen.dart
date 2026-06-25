import 'dart:ui' as ui;

import 'package:avo_app/app/features/profile/logic/profile_cubit.dart';
import 'package:avo_app/app/features/profile/logic/profile_state.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/Language/locale_keys.g.dart'; // 🔥 الـ LocaleKeys

class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({super.key});

  AccountInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          // 🔥 قلب السهم في حالة اللغة العربية
          icon: Transform.flip(
            flipX: context.locale.languageCode == 'ar',
            child: Icon(Icons.arrow_back_ios_new,
                color: theme.colorScheme.onSurface),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          LocaleKeys.account_info_title.tr(), // 🔥 ترجمة العنوان
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: colorScheme.error,
              ),
            );
          } else if (state is ProfileSuccess && isEditMode) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(LocaleKeys.account_info_update_success.tr()), // 🔥 ترجمة رسالة النجاح
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
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      context,
                      label: LocaleKeys.account_info_full_name.tr(), // 🔥 ترجمة الاسم
                      controller: cubit.fullNameController,
                      enabled: isEditMode,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      context,
                      label: LocaleKeys.account_info_phone.tr(), // 🔥 ترجمة التليفون
                      controller: cubit.phoneController,
                      enabled: isEditMode,
                      keyboardType: TextInputType.phone,
                      // 🔥 يفضل نخلي أرقام التليفون تقرأ من الشمال لليمين دايماً
                      textDirection: ui.TextDirection.ltr,                    ),
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
                      ? colorScheme.primary
                      : colorScheme.onSurface.withValues(alpha: 0.2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  // 🔥 استخدام الكلمات المشتركة
                  isEditMode ? LocaleKeys.general_save.tr() : LocaleKeys.general_edit.tr(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isEditMode
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              context,
              label: 'Email',
              initialValue: userData.email,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              context,
              label: 'Phone',
              initialValue: userData.phoneNumber,
            ),
          ],
        ),
      ),
    );
  }

  // 💡 ضفنا TextDirection للتحكم في الحقول اللي بتحتوي على أرقام زي التليفون
  Widget _buildTextField(
      BuildContext context, {
        required String label,
        required TextEditingController controller,
        required bool enabled,
        TextInputType keyboardType = TextInputType.text,
        TextDirection? textDirection,
      }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          textDirection: textDirection, // 💡 تمرير الاتجاه
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 16.sp,
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(
                color: theme.colorScheme.onSurface,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: theme.cardColor,
          ),
        ),
      ],
    );
  }
}