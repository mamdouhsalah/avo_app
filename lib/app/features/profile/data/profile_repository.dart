import 'dart:io';
import 'package:avo_app/app/core/models/user_profile_model.dart';

abstract class ProfileRepository {
  Future<void> logout();
  Future<UserProfileModel> getProfile(String uid);
  Future<void> updateProfile(String uid, Map<String, dynamic> data);
  Future<String> uploadAvatar(File file);
}