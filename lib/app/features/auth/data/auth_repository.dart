import 'package:avo_app/app/core/models/auth_response_model.dart';
import 'package:avo_app/app/core/models/login_request_model.dart';
import 'package:avo_app/app/core/models/register_request_model.dart';
import 'package:avo_app/app/core/models/user_profile_model.dart';

abstract class AuthRepository {
  Future<UserProfileModel> login(
    LoginRequestModel loginRequestModel
  );
  Future<UserProfileModel> register(
    RegisterRequestModel registerRequestModel
  );
  Future<UserProfileModel?> checkToken();
  Future<void> forgetPassword(
    String email
  );
  Future<AuthResponseModel> updateProfile(
    String name,
    String email,
    String phone,
    String gender,
    String dateOfBirth,
  );
  Future<void> logout();

  Future<void> reresetPassword(
    String email
  );
}