import 'package:avo_app/app/core/models/user_profile_model.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileSuccess extends ProfileState {
  final UserProfileModel userProfile;
  ProfileSuccess(this.userProfile);
}

class ProfileFailure extends ProfileState {
  final String error;
  ProfileFailure(this.error);
}