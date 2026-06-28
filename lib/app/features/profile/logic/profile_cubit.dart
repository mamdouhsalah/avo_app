import 'dart:io';
import 'package:avo_app/app/core/models/user_profile_model.dart';
import 'package:avo_app/app/core/models/doctor_model.dart';
import 'package:avo_app/app/core/theme/theme_cubit.dart';
import 'package:avo_app/app/features/profile/data/profile_repository.dart';
import 'package:avo_app/app/features/profile/logic/profile_state.dart';
import 'package:easy_localization/easy_localization.dart'; // 🔥 الترجمة
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/Language/locale_keys.g.dart'; // 🔥 الـ LocaleKeys

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository repository;

  // Controllers
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final dobController = TextEditingController();

  // Doctor-specific Controllers
  final docLocationController = TextEditingController();
  final docPriceController = TextEditingController();
  final docBioController = TextEditingController();
  String? selectedSpecialty;

  String selectedGender = 'Male';
  String imageUrl = '';
  UserProfileModel? userProfile;

  ProfileCubit(this.repository) : super(ProfileInitial());

  Future<void> getProfile() async {
    try {
      emit(ProfileLoading());
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (uid.isEmpty) {
        emit(ProfileFailure(
            LocaleKeys.profile_unauthenticated.tr())); // 🔥 ترجمة رسالة الخطأ
        return;
      }
      final profile = await repository.getProfile(uid);
      userProfile = profile;

      // Populate controllers
      fullNameController.text = profile.fullName;
      phoneController.text = profile.phoneNumber;
      heightController.text = profile.height?.toString() ?? '';
      weightController.text = profile.weight?.toString() ?? '';
      dobController.text = profile.dateOfBirth;

      // Populate state fields
      selectedGender = profile.gender.isEmpty
          ? 'Male'
          : '${profile.gender[0].toUpperCase()}${profile.gender.substring(1).toLowerCase()}';
      imageUrl = profile.image;

      if (profile is DoctorModel) {
        docLocationController.text = profile.location ?? '';
        docPriceController.text = profile.price.toString();
        docBioController.text = profile.bio;
        selectedSpecialty = profile.specialty.toLowerCase();
      }

      emit(ProfileSuccess(profile));
    } catch (e) {
      emit(ProfileFailure(e.toString()));
    }
  }

  Future<void> getDoctorProfile(String doctorId) async {
    try {
      emit(ProfileLoading());
      final profile = await repository.getProfile(doctorId);
      if (profile is DoctorModel) {
        docLocationController.text = profile.location ?? '';
        docPriceController.text = profile.price.toString();
        docBioController.text = profile.bio;
        selectedSpecialty = profile.specialty.toLowerCase();
      }
      emit(ProfileSuccess(profile));
    } catch (e) {
      emit(ProfileFailure(e.toString()));
    }
  }

  Future<void> updateDoctorProfile(String doctorId) async {
    try {
      emit(ProfileLoading());
      final updates = {
        'location': docLocationController.text.trim(),
        'price': double.tryParse(docPriceController.text.trim()) ?? 0.0,
        'bio': docBioController.text.trim(),
        'specialty': selectedSpecialty ?? '',
      };
      await repository.updateProfile(doctorId, updates);
      
      final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (doctorId == currentUid) {
        await getProfile();
      } else {
        await getDoctorProfile(doctorId);
      }
    } catch (e) {
      emit(ProfileFailure(e.toString()));
    }
  }

  Future<void> updateProfile() async {
    try {
      emit(ProfileLoading());
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (uid.isEmpty) {
        emit(ProfileFailure(
            LocaleKeys.profile_unauthenticated.tr())); // 🔥 ترجمة رسالة الخطأ
        return;
      }

      final height = double.tryParse(heightController.text.trim());
      if ((height == null || height < 30 || height > 210) && (userProfile == null || userProfile!.role != 'doctor')) {
        emit(ProfileFailure(LocaleKeys.auth_error_invalid_height.tr()));
        return;
      }

      final weight = double.tryParse(weightController.text.trim());
      if ((weight == null || weight < 8 || weight > 220) && (userProfile == null || userProfile!.role != 'doctor')) {
        emit(ProfileFailure(LocaleKeys.auth_error_invalid_weight.tr()));
        return;
      }

      final data = {
        'full_name': fullNameController.text.trim(),
        'phone_number': phoneController.text.trim(),
        'height': height,
        'weight': weight,
        'date_of_birth': dobController.text.trim(),
        'gender': selectedGender.toLowerCase(),
      };

      await repository.updateProfile(uid, data);

      // Re-fetch profile to ensure state matches DB
      await getProfile();
    } catch (e) {
      emit(ProfileFailure(e.toString()));
    }
  }

  Future<void> uploadAvatar(File imageFile) async {
    try {
      emit(ProfileLoading());
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (uid.isEmpty) {
        emit(ProfileFailure(
            LocaleKeys.profile_unauthenticated.tr())); // 🔥 ترجمة رسالة الخطأ
        return;
      }

      final uploadedUrl = await repository.uploadAvatar(imageFile);
      await repository.updateProfile(uid, {'image': uploadedUrl});

      // Re-fetch profile
      await getProfile();
    } catch (e) {
      emit(ProfileFailure(e.toString()));
    }
  }

  Future<void> logout() async {
    try {
      emit(ProfileLoading());
      await repository.logout();
      emit(ProfileLogout());
    } catch (e) {
      emit(ProfileFailure(e.toString()));
    }
  }

  Future<void> changeTheme(ThemeMode mode, BuildContext context) async {
    context.read<ThemeCubit>().setTheme(mode);
  }

  Future<void> changeLanguage(String languageCode, BuildContext context) async {
    await context.setLocale(Locale(languageCode));
    await repository.saveLanguage(languageCode);
  }

  @override
  Future<void> close() {
    fullNameController.dispose();
    phoneController.dispose();
    heightController.dispose();
    weightController.dispose();
    dobController.dispose();
    docLocationController.dispose();
    docPriceController.dispose();
    docBioController.dispose();
    return super.close();
  }
}
