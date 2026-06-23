import 'dart:developer';
import 'dart:io';

import 'package:avo_app/app/core/errors/database_exception.dart';
import 'package:avo_app/app/core/models/auth_response_model.dart';
import 'package:avo_app/app/core/models/login_request_model.dart';
import 'package:avo_app/app/core/models/register_request_model.dart';

import 'package:avo_app/app/core/models/user_profile_model.dart';
import 'package:avo_app/app/core/services/remote/cloudinary_service.dart';
import 'package:avo_app/app/core/services/remote/firebase_consumer.dart';
import 'package:avo_app/app/features/auth/data/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseConsumer _consumer;
  final FirebaseAuth _firebaseAuth;
  final CloudinaryService _cloudinaryService;

  AuthRepositoryImpl({
    required FirebaseConsumer consumer,
    FirebaseAuth? firebaseAuth,
    CloudinaryService? cloudinaryService,
  })  : _consumer = consumer,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _cloudinaryService = cloudinaryService ?? CloudinaryService();

  @override
  Future<UserProfileModel> register(
      RegisterRequestModel registerRequestModel) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: registerRequestModel.email,
        password: registerRequestModel.password,
      );

      final uid = credential.user?.uid ?? '';

      final userData = registerRequestModel.toJson();
      userData.remove('password');

      String imageUrl = '';
      if (registerRequestModel.image != null &&
          registerRequestModel.image!.isNotEmpty) {
        log("message: ${registerRequestModel.image}");
        try {
          imageUrl = await _cloudinaryService
              .uploadImage(File(registerRequestModel.image!));
        } catch (e) {
          log("imageurl Failed: $e");
        }
        log("imageurl: $imageUrl");
      }
      userData['image'] = imageUrl;

      await _consumer.set('users/$uid', data: userData);
      final isVerified = credential.user?.emailVerified ?? false;

      if (!isVerified) {
        try {
          await _firebaseAuth.currentUser!.sendEmailVerification();
        } catch (e) {
          log("Email verification failed: $e");
        }
      }

      return UserProfileModel(
        id: uid,
        email: registerRequestModel.email,
        fullName: registerRequestModel.fullName,
        role: registerRequestModel.role,
        gender: registerRequestModel.gender,
        dateOfBirth: registerRequestModel.dateOfBirth,
        phoneNumber: registerRequestModel.phoneNumber,
        height: registerRequestModel.height.toInt(),
        weight: registerRequestModel.weight.toInt(),
        image: imageUrl,
        isVerified: false, // Admin needs to approve
      );
    } on FirebaseAuthException catch (e) {
      throw DatabaseException(e.message ?? 'Registration failed', e.code);
    } catch (e) {
      throw DatabaseException(e.toString(), 'unknown-error');
    }
  }

  @override
  Future<UserProfileModel> login(LoginRequestModel loginRequestModel) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: loginRequestModel.email,
        password: loginRequestModel.password,
      );

      final uid = credential.user?.uid ?? '';

      final userProfile = await _consumer.get<UserProfileModel>(
        'users/$uid',
        fromJson: (json) => UserProfileModel.fromJson(json, id: uid),
      );

      final isEmailVerified = _firebaseAuth.currentUser!.emailVerified;
      if (!isEmailVerified) {
        try {
          await _firebaseAuth.currentUser!.sendEmailVerification();
        } catch (e) {
          log("Email verification failed: $e");
        }
      }

      final isAdminVerified = userProfile.isVerified == true || userProfile.role == 'admin';

      return UserProfileModel(
        id: uid,
        email: userProfile.email,
        fullName: userProfile.fullName,
        role: userProfile.role,
        gender: userProfile.gender,
        dateOfBirth: userProfile.dateOfBirth,
        phoneNumber: userProfile.phoneNumber,
        height: userProfile.height,
        weight: userProfile.weight,
        image: userProfile.image,
        isVerified: isAdminVerified,
      );
    } on FirebaseAuthException catch (e) {
      throw DatabaseException(e.message ?? 'Login failed', e.code);
    } catch (e) {
      throw DatabaseException(e.toString(), 'unknown-error');
    }
  }

  @override
  Future<AuthResponseModel> logout() async {
    try {
      await _firebaseAuth.signOut();
      return AuthResponseModel(
          id: '',
          email: '',
          fullName: '',
          token: '',
          role: '',
          gender: '',
          expiresIn: 0);
    } catch (e) {
      throw DatabaseException(e.toString(), 'logout-failed');
    }
  }

  @override
  Future<AuthResponseModel> forgetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return AuthResponseModel(
          id: '',
          email: email,
          fullName: '',
          token: '',
          role: '',
          gender: '',
          expiresIn: 0);
    } catch (e) {
      throw DatabaseException(e.toString(), 'password-reset-failed');
    }
  }

  @override
  Future<AuthResponseModel> verifyCode(String code, String email) async {
    return AuthResponseModel(
        id: '',
        email: email,
        fullName: '',
        token: '',
        role: '',
        gender: '',
        expiresIn: 0);
  }

  @override
  Future<AuthResponseModel> resetPassword(
      String password, String confirmPassword, String token) async {
    return AuthResponseModel(
        id: '',
        email: '',
        fullName: '',
        token: '',
        role: '',
        gender: '',
        expiresIn: 0);
  }

  @override
  Future<AuthResponseModel> changePassword(
      String password, String confirmPassword, String token) async {
    return AuthResponseModel(
        id: '',
        email: '',
        fullName: '',
        token: '',
        role: '',
        gender: '',
        expiresIn: 0);
  }

  @override
  Future<AuthResponseModel> verifyEmail(String email) async {
    return AuthResponseModel(
        id: '',
        email: email,
        fullName: '',
        token: '',
        role: '',
        gender: '',
        expiresIn: 0);
  }

  @override
  Future<AuthResponseModel> updateProfile(
    String name,
    String email,
    String phone,
    String gender,
    String dateOfBirth,
  ) async {
    try {
      final uid = _firebaseAuth.currentUser?.uid ?? '';
      final updates = {
        'full_name': name,
        'email': email,
        'phone_number': phone,
        'gender': gender,
        'date_of_birth': dateOfBirth,
      };
      await _consumer.update('users/$uid', data: updates);
      return AuthResponseModel(
        id: uid,
        email: email,
        fullName: name,
        token: '',
        role: '',
        gender: gender,
        expiresIn: 0,
      );
    } catch (e) {
      throw DatabaseException(e.toString(), 'update-profile-failed');
    }
  }

  @override
  Future<UserProfileModel?> checkToken() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        final UserProfileModel userProfile =
            await _consumer.get<UserProfileModel>(
          'users/${user.uid}',
          fromJson: (json) => UserProfileModel.fromJson(json, id: user.uid),
        );
        return userProfile;
      } else {
        return null;
      }
    } catch (e) {
      throw DatabaseException(e.toString(), 'check-token-failed');
    }
  }

  @override
  Future<void> reresetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw DatabaseException(e.toString(), 'reset-password-failed');
    }
  }
}
