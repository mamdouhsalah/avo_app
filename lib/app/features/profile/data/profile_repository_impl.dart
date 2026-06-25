import 'dart:io';
import 'package:avo_app/app/core/errors/database_exception.dart';
import 'package:avo_app/app/core/models/user_profile_model.dart';
import 'package:avo_app/app/core/services/remote/cloudinary_service.dart';
import 'package:avo_app/app/core/services/remote/firebase_consumer.dart';
import 'package:avo_app/app/features/profile/data/profile_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileRepositoryImpl extends ProfileRepository {
  final FirebaseConsumer _consumer;
  final FirebaseAuth _firebaseAuth;
  final CloudinaryService _cloudinaryService;

  ProfileRepositoryImpl({
    required FirebaseConsumer consumer,
    FirebaseAuth? firebaseAuth,
    CloudinaryService? cloudinaryService,
  })  : _consumer = consumer,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _cloudinaryService = cloudinaryService ?? CloudinaryService();

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
        fromJson: (json) => UserProfileModel.fromJson(json, id: uid),
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
}
