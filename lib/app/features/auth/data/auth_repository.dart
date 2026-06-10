import 'package:avo_app/app/core/models/auth_response_model.dart';
import 'package:avo_app/app/core/models/login_request_model.dart';
import 'package:avo_app/app/core/models/register_request_model.dart';

abstract class AuthRepository {
  Future<AuthResponseModel> login(
    LoginRequestModel loginRequestModel
  );
  Future<AuthResponseModel> register(
    RegisterRequestModel registerRequestModel
  );
  Future<AuthResponseModel> forgetPassword(
    String email
  );
  Future<AuthResponseModel> verifyCode(
    String code,
    String email
  );
  Future<AuthResponseModel> resetPassword(
    String password,
    String confirmPassword,
    String token
  );
  Future<AuthResponseModel> changePassword(
    String password,
    String confirmPassword,
    String token
  );
  Future<AuthResponseModel> verifyEmail(String email);
  Future<AuthResponseModel> updateProfile(
    String name,
    String email,
    String phone,
    String gender,
    String dateOfBirth,
  );
  Future<AuthResponseModel> logout();
}