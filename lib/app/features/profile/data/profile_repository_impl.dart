import 'dart:io';
import 'package:avo_app/app/core/constants/database_paths.dart';
import 'package:avo_app/app/core/errors/database_exception.dart';
import 'package:avo_app/app/core/models/patient_model.dart';
import 'package:avo_app/app/core/models/user_profile_model.dart';
import 'package:avo_app/app/core/models/doctor_model.dart';
import 'package:avo_app/app/core/services/local/preferences_service.dart';
import 'package:avo_app/app/core/services/remote/cloudinary_service.dart';
import 'package:avo_app/app/core/services/remote/firebase_consumer.dart';
import 'package:avo_app/app/features/profile/data/profile_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileRepositoryImpl extends ProfileRepository {
  final FirebaseConsumer _consumer;
  final FirebaseAuth _firebaseAuth;
  final CloudinaryService _cloudinaryService;
  final PreferencesService _preferencesService;

  ProfileRepositoryImpl({
    required FirebaseConsumer consumer,
    FirebaseAuth? firebaseAuth,
    CloudinaryService? cloudinaryService,
    PreferencesService? preferencesService,
  })  : _consumer = consumer,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _cloudinaryService = cloudinaryService ?? CloudinaryService(),
        _preferencesService = preferencesService ?? PreferencesService();

  @override
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw DatabaseException(e.toString(), 'logout-failed');
    }
  }

  @override
  Future<UserProfileModel> getProfile(String uid) async {
    try {
      final userProfile = await _consumer.get<UserProfileModel>(
        'users/$uid',
        fromJson: (json) {
          if (json['role'] == 'doctor') {
            return DoctorModel.fromJson(json);
          }
          return UserProfileModel.fromJson(json, id: uid);
        },
      );
      return userProfile;
    } catch (e) {
      throw DatabaseException(e.toString(), 'get-profile-failed');
    }
  }

  @override
  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _consumer.update('users/$uid', data: data);

      final snap = await _consumer.get('users/$uid', fromJson: (json) => json);
      if (snap['role'] == 'doctor') {
        final Map<String, dynamic> doctorUpdates = {};
        if (data.containsKey('specialty'))
          doctorUpdates['specialty'] = data['specialty'];
        if (data.containsKey('location'))
          doctorUpdates['location'] = data['location'];
        if (data.containsKey('price')) doctorUpdates['price'] = data['price'];
        if (data.containsKey('bio')) doctorUpdates['bio'] = data['bio'];
        if (data.containsKey('full_name')) {
          doctorUpdates['fullName'] = data['full_name'];
        }
        if (data.containsKey('image')) doctorUpdates['image'] = data['image'];

        if (doctorUpdates.isNotEmpty) {
          await _consumer.update('doctors/$uid', data: doctorUpdates);
        }
      }
    } catch (e) {
      throw DatabaseException(e.toString(), 'update-profile-failed');
    }
  }

  @override
  Future<String> uploadAvatar(File file) async {
    try {
      return await _cloudinaryService.uploadImage(file);
    } catch (e) {
      throw DatabaseException(e.toString(), 'upload-avatar-failed');
    }
  }

  @override
  Future<PatientModel> getUserIfPatientById(String patientId) {
    try {
      final user = _consumer.get<PatientModel>(
          '${DatabasePaths.users}/$patientId',
          fromJson: (json) => PatientModel.fromJson(json, id: patientId));
      return user;
    } catch (e) {
      throw DatabaseException(
          e.toString(), 'user is not found or is not a patient');
    }
  }

  String? getSavedLanguage() => _preferencesService.getLanguage();

  @override
  String? getSavedTheme() => _preferencesService.getTheme();

  @override
  Future<void> saveLanguage(String languageCode) =>
      _preferencesService.saveLanguage(languageCode);

  @override
  Future<void> saveTheme(ThemeMode mode) {
    if (mode == ThemeMode.system) return _preferencesService.clearTheme();
    return _preferencesService
        .saveTheme(mode == ThemeMode.dark ? 'dark' : 'light');
  }
}
