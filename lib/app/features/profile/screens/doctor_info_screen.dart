import 'package:avo_app/app/core/Language/locale_keys.g.dart';
import 'package:avo_app/app/core/shared/custom_text_form_field.dart';
import 'package:avo_app/app/features/profile/logic/profile_cubit.dart';
import 'package:avo_app/app/features/profile/logic/profile_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class DoctorInfoScreen extends StatefulWidget {
  final String? doctorId;

  const DoctorInfoScreen({super.key, this.doctorId});

  @override
  State<DoctorInfoScreen> createState() => _DoctorInfoScreenState();
}

class _DoctorInfoScreenState extends State<DoctorInfoScreen> {
  bool _isEditMode = false;
  late final String _resolvedDoctorId;

  @override
  void initState() {
    super.initState();
    _resolvedDoctorId =
        widget.doctorId ?? FirebaseAuth.instance.currentUser?.uid ?? '';
    context.read<ProfileCubit>().getDoctorProfile(_resolvedDoctorId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isMe = _resolvedDoctorId == FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Transform.flip(
            flipX: context.locale.languageCode == 'ar',
            child: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          LocaleKeys.profile_doctor_info.tr(),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (isMe)
            IconButton(
              icon: Icon(
                _isEditMode ? Icons.close_rounded : Icons.edit_rounded,
                color: _isEditMode ? Colors.red : colorScheme.primary,
              ),
              onPressed: () {
                setState(() {
                  _isEditMode = !_isEditMode;
                });
              },
            ),
        ],
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
          } else if (state is ProfileSuccess && _isEditMode) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(LocaleKeys.profile_doctor_info_update_success.tr()),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            );
            setState(() {
              _isEditMode = false;
            });
          }
        },
        builder: (context, state) {
          final cubit = context.read<ProfileCubit>();
          final isLoading = state is ProfileLoading;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ================= HEADER BANNER =================
                    _buildHeaderBanner(theme),
                    SizedBox(height: 24.h),

                    // ================= LOCATION & CLINIC =================
                    Text(
                      'Workplace Details',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Clinic Field
                    CustomTextFormField(
                      controller: cubit.docClinicController,
                      labelText: 'Clinic / Hospital Name',
                      hintText: 'Enter your clinic or hospital name',
                      prefixIcon: const Icon(Icons.local_hospital_outlined),
                      readOnly: !_isEditMode,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: 16.h),

                    // Location Field
                    CustomTextFormField(
                      controller: cubit.docLocationController,
                      labelText: LocaleKeys.auth_location.tr(),
                      hintText: LocaleKeys.auth_location_hint.tr(),
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      readOnly: !_isEditMode,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: 24.h),

                    // ================= SPECIALTY & PRICE =================
                    Text(
                      'Professional Info',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Specialty Dropdown
                    _buildSpecialtyDropdown(cubit, theme),
                    SizedBox(height: 16.h),

                    // Price Field
                    CustomTextFormField(
                      controller: cubit.docPriceController,
                      labelText: LocaleKeys.auth_price.tr(),
                      hintText: LocaleKeys.auth_price_hint.tr(),
                      prefixIcon: const Icon(Icons.attach_money_outlined),
                      keyboardType: TextInputType.number,
                      readOnly: !_isEditMode,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: 24.h),

                    // ================= BIO =================
                    Text(
                      'Biography',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Bio Field
                    CustomTextFormField(
                      controller: cubit.docBioController,
                      labelText: 'Bio',
                      hintText:
                          'Write a brief description about your experience and qualifications',
                      prefixIcon: const Icon(Icons.description_outlined),
                      readOnly: !_isEditMode,
                      textInputAction: TextInputAction.done,
                    ),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
              if (isLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.2),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final isLoading = state is ProfileLoading;
          if (isLoading || !_isEditMode) return const SizedBox.shrink();

          return Container(
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              bottom: 20.h + MediaQuery.of(context).padding.bottom,
              top: 16.h,
            ),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 55.h,
              child: ElevatedButton(
                onPressed: () {
                  context
                      .read<ProfileCubit>()
                      .updateDoctorProfile(_resolvedDoctorId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  LocaleKeys.general_save.tr(),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= HEADER BANNER =================
  Widget _buildHeaderBanner(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.medical_services_rounded,
              size: 32.sp,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Doctor Profile',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Manage your professional details to attract more patients.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= SPECIALTY DROPDOWN =================
  Widget _buildSpecialtyDropdown(ProfileCubit cubit, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.auth_specialty.tr(),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        Builder(builder: (context) {
          final specialties = [
            'cardiologist',
            'neurosurgeon',
            'orthopedic',
            'pediatrician',
            'dermatologist',
            'gynecologist',
            'dentist',
            'ent',
            'ophthalmologist',
            'general_practitioner',
          ];

          String? initialSpecialty = cubit.selectedSpecialty;
          if (initialSpecialty != null &&
              !specialties.contains(initialSpecialty)) {
            initialSpecialty = null;
          }

          return DropdownButtonFormField<String>(
            initialValue: initialSpecialty,
            hint: Text(
              LocaleKeys.auth_specialty_hint.tr(),
              style: TextStyle(
                fontSize: 14.sp,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            icon: Icon(Icons.keyboard_arrow_down_rounded,
                color: _isEditMode ? colorScheme.primary : Colors.grey),
            decoration: InputDecoration(
              prefixIcon: IconTheme(
                data: IconThemeData(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  size: 20.sp,
                ),
                child: const Icon(Icons.stars_outlined),
              ),
              filled: true,
              fillColor: _isEditMode
                  ? theme.cardColor
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 1.w,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 1.w,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(
                  color: colorScheme.primary,
                  width: 1.5.w,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide.none,
              ),
            ),
            items: specialties.map((spec) {
              String transKey = 'auth.specialties.$spec';
              return DropdownMenuItem<String>(
                value: spec,
                enabled: _isEditMode,
                child: Text(
                  transKey.tr(),
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
              );
            }).toList(),
            onChanged: _isEditMode
                ? (val) {
                    setState(() {
                      cubit.selectedSpecialty = val;
                    });
                  }
                : null,
          );
        }),
      ],
    );
  }
}
