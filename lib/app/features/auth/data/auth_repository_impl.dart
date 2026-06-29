import 'dart:developer';
import 'dart:io';

import 'package:avo_app/app/core/errors/database_exception.dart';
import 'package:avo_app/app/core/models/auth_response_model.dart';
import 'package:avo_app/app/core/models/login_request_model.dart';
import 'package:avo_app/app/core/models/register_request_model.dart';

import 'package:avo_app/app/core/constants/database_paths.dart';
import 'package:avo_app/app/core/models/doctor_model.dart';
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

      if (registerRequestModel.role == 'doctor') {
        final doctorModel = DoctorModel(
          id: uid,
          email: registerRequestModel.email,
          fullName: registerRequestModel.fullName,
          role: registerRequestModel.role,
          gender: registerRequestModel.gender,
          dateOfBirth: registerRequestModel.dateOfBirth,
          phoneNumber: registerRequestModel.phoneNumber,
          image: imageUrl,
          isVerified: false,
          specialty: registerRequestModel.specialty ?? '',
          location: registerRequestModel.location,
          rating: 0.0,
          numberOfReviews: 0,
          price: (registerRequestModel.price ?? 0.0).toDouble(),
          bio: '',
        );
        await _consumer.set('${DatabasePaths.doctors}/$uid', data: doctorModel.toJson());
      }

      final user = credential.user;
      if (user == null) {
        throw DatabaseException('User not found after registration', 'user-not-found');
      }
      final isVerified = user.emailVerified;

      if (!isVerified) {
        await user.sendEmailVerification();
      }

      return UserProfileModel(
        id: uid,
        email: registerRequestModel.email,
        fullName: registerRequestModel.fullName,
        role: registerRequestModel.role,
        gender: registerRequestModel.gender,
        dateOfBirth: registerRequestModel.dateOfBirth,
        phoneNumber: registerRequestModel.phoneNumber,
        height: registerRequestModel.height?.toInt(),
        weight: registerRequestModel.weight?.toInt(),
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

      final user = credential.user;
      if (user == null) {
        throw DatabaseException('User not found after login', 'user-not-found');
      }
      final isVerified = user.emailVerified;

      if (!isVerified) {
        await user.sendEmailVerification();
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
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw DatabaseException(e.toString(), 'logout-failed');
    }
  }

  @override
  Future<void> forgetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw DatabaseException(e.toString(), 'password-reset-failed');
    }
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
