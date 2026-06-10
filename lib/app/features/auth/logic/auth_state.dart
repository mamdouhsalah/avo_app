import 'package:avo_app/app/core/models/auth_response_model.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final AuthResponseModel response;
  AuthSuccess(this.response);
}

class AuthFailure extends AuthState {
  final String error;
  AuthFailure(this.error);
}

class AuthStepChanged extends AuthState {
  final int step;
  AuthStepChanged(this.step);
}