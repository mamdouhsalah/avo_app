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
    _resolvedDoctorId = widget.doctorId ?? FirebaseAuth.instance.currentUser?.uid ?? '';
    context.read<ProfileCubit>().getDoctorProfile(_resolvedDoctorId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                content: Text(LocaleKeys.profile_doctor_info_update_success.tr()),
                backgroundColor: Colors.green,
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
                    // Location Field
                    CustomTextFormField(
                      controller: cubit.docLocationController,
                      labelText: LocaleKeys.auth_location.tr(),
                      hintText: LocaleKeys.auth_location_hint.tr(),
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      readOnly: !_isEditMode,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: 20.h),

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
                    SizedBox(height: 20.h),

                    // Specialty Dropdown
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LocaleKeys.auth_specialty.tr(),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        DropdownButtonFormField<String>(
                          initialValue: cubit.selectedSpecialty,
                          hint: Text(
                            LocaleKeys.auth_specialty_hint.tr(),
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
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
                              vertical: 14.h,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r),
                              borderSide: BorderSide(
                                color: colorScheme.outlineVariant,
                                width: 1.w,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r),
                              borderSide: BorderSide(
                                color: colorScheme.outlineVariant,
                                width: 1.w,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r),
                              borderSide: BorderSide(
                                color: colorScheme.primary,
                                width: 1.w,
                              ),
                            ),
                          ),
                          items: [
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
                          ].map((spec) {
                            String transKey = 'auth.specialties.$spec';
                            return DropdownMenuItem<String>(
                              value: spec,
                              enabled: _isEditMode,
                              child: Text(
                                transKey.tr(),
                                style: TextStyle(
                                  fontSize: 16.sp,
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
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    // Bio Field
                    CustomTextFormField(
                      controller: cubit.docBioController,
                      labelText: 'Bio',
                      hintText: 'Enter doctor bio/description',
                      prefixIcon: const Icon(Icons.description_outlined),
                      readOnly: !_isEditMode,
                      textInputAction: TextInputAction.done,
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const Center(child: CircularProgressIndicator()),
            ],
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final isLoading = state is ProfileLoading;
          if (isLoading) return const SizedBox.shrink();
          return Container(
            padding: const EdgeInsets.all(20),
            color: theme.scaffoldBackgroundColor,
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  if (_isEditMode) {
                    context.read<ProfileCubit>().updateDoctorProfile(_resolvedDoctorId);
                  } else {
                    setState(() {
                      _isEditMode = true;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isEditMode
                      ? colorScheme.primary
                      : colorScheme.onSurface.withValues(alpha: 0.2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  _isEditMode ? LocaleKeys.general_save.tr() : LocaleKeys.general_edit.tr(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _isEditMode
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
