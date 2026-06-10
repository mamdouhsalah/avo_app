import 'package:avo_app/app/core/Language/locale_keys.g.dart';
import 'package:avo_app/app/features/auth/logic/auth_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RoleCreateAccountSection extends StatelessWidget {
  final AuthCubit cubit;

  const RoleCreateAccountSection({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final List<Map<String, dynamic>> roles = [
      {
        'key': 'doctor',
        'title': LocaleKeys.auth_doctor,
        'image': 'assets/svg/roles/doctor.png'
      },
      {
        'key': 'patient',
        'title': LocaleKeys.auth_patient,
        'image': 'assets/svg/roles/patient.png'
      },
      {
        'key': 'radiology_specialist',
        'title': LocaleKeys.auth_radiology_specialist,
        'image': 'assets/svg/roles/admin.png'
      },
      {
        'key': 'pharmacy_specialist',
        'title': LocaleKeys.auth_pharmacy_specialist,
        'image': 'assets/svg/roles/pharmacy.png'
      },
      {
        'key': 'laboratory_specialist',
        'title': LocaleKeys.auth_laboratory_specialist,
        'image': 'assets/svg/roles/hospital.png'
      },
    ];

    return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(vertical: 8.h),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 16.h,
          childAspectRatio: 1.1,
        ),
        itemCount: roles.length,
        itemBuilder: (context, index) {
          final role = roles[index];
          final isSelected = cubit.selectedRole == role['key'];

          return GestureDetector(
            onTap: () {
              cubit.selectedRole = role['key']!;
              cubit.setStep(0);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary.withValues(alpha: 0.05)
                    : colorScheme.surface,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
                  width: isSelected ? 2.w : 1.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary.withValues(alpha: 0.15)
                          : colorScheme.primary.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      role['image']!,
                      width: 36.w,
                      height: 36.h,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.person_outline,
                        color: colorScheme.primary,
                        size: 36.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Text(
                      (role['title'] as String).tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
  }
}
