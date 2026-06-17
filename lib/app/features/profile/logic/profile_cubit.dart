import 'dart:io';
import 'package:avo_app/app/core/models/user_profile_model.dart';
import 'package:avo_app/app/features/profile/data/profile_repository.dart';
import 'package:avo_app/app/features/profile/logic/profile_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository repository;

  // Controllers
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final dobController = TextEditingController();

  String selectedGender = 'Male';
  String imageUrl = '';
  UserProfileModel? userProfile;

  ProfileCubit(this.repository) : super(ProfileInitial());

  Future<void> getProfile() async {
    try {
      emit(ProfileLoading());
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (uid.isEmpty) {
        emit(ProfileFailure('User not authenticated'));
        return;
      }
      final profile = await repository.getProfile(uid);
      userProfile = profile;

      // Populate controllers
      fullNameController.text = profile.fullName;
      phoneController.text = profile.phoneNumber;
      heightController.text = profile.height.toString();
      weightController.text = profile.weight.toString();
      dobController.text = profile.dateOfBirth;

      // Populate state fields
      selectedGender = profile.gender.isEmpty
          ? 'Male'
          : '${profile.gender[0].toUpperCase()}${profile.gender.substring(1).toLowerCase()}';
      imageUrl = profile.image;

      emit(ProfileSuccess(profile));
    } catch (e) {
      emit(ProfileFailure(e.toString()));
    }
  }

  Future<void> updateProfile() async {
    try {
      emit(ProfileLoading());
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (uid.isEmpty) {
        emit(ProfileFailure('User not authenticated'));
        return;
      }

      final data = {
        'full_name': fullNameController.text.trim(),
        'phone_number': phoneController.text.trim(),
        'height': double.tryParse(heightController.text.trim())?.toInt() ?? 0,
        'weight': double.tryParse(weightController.text.trim())?.toInt() ?? 0,
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
        emit(ProfileFailure('User not authenticated'));
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

  @override
  Future<void> close() {
    fullNameController.dispose();
    phoneController.dispose();
    heightController.dispose();
    weightController.dispose();
    dobController.dispose();
    return super.close();
  }
}
