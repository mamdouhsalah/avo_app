import 'package:avo_app/app/core/Language/locale_keys.g.dart';
import 'package:avo_app/app/core/models/login_request_model.dart';
import 'package:avo_app/app/core/models/register_request_model.dart';
import 'package:avo_app/app/core/services/admin_log_service.dart';
import 'package:avo_app/app/features/auth/data/auth_repository.dart';
import 'package:avo_app/app/features/auth/logic/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository;

  // Controllers
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Selection states
  String selectedRole = 'patient';
  String? selectedGender;
  DateTime? selectedDob;
  String? profileImagePath;

  // Step state
  int currentStep = 0;

  AuthCubit({required this.repository}) : super(AuthInitial());

  void setStep(int step) {
    currentStep = step;
    emit(AuthStepChanged(step));
  }

  bool nextStep() {
    final validationError = validateCurrentStep();
    if (validationError != null) {
      emit(AuthFailure(validationError));
      return false;
    }
    if (currentStep < 3) {
      currentStep++;
      emit(AuthStepChanged(currentStep));
      return true;
    }
    return false;
  }

  void previousStep() {
    if (currentStep > 0) {
      currentStep--;
      emit(AuthStepChanged(currentStep));
    }
  }

  String? validateCurrentStep() {
    if (currentStep == 0) {
      if (selectedRole.isEmpty) {
        return LocaleKeys.auth_error_select_role;
      }
    } else if (currentStep == 1) {
      if (fullNameController.text.trim().length < 3) {
        return LocaleKeys.auth_error_invalid_name;
      }
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
      if (!emailRegex.hasMatch(emailController.text.trim())) {
        return LocaleKeys.auth_error_invalid_email;
      }
      if (phoneController.text.trim().isEmpty) {
        return LocaleKeys.auth_error_invalid_phone;
      }
    } else if (currentStep == 2) {
      if (selectedGender == null || selectedGender!.isEmpty) {
        return LocaleKeys.auth_error_select_gender;
      }
      final height = double.tryParse(heightController.text.trim());
      if ((height == null || height < 30 || height > 210) && selectedRole != 'doctor') {
        return LocaleKeys.auth_error_invalid_height;
      }
      final weight = double.tryParse(weightController.text.trim());
      if ((weight == null || weight < 8 || weight > 220) && selectedRole != 'doctor') {
        return LocaleKeys.auth_error_invalid_weight;
      }
      if (selectedDob == null) {
        return LocaleKeys.auth_error_select_dob;
      }
    } else if (currentStep == 3) {
      if (passwordController.text.length < 6) {
        return LocaleKeys.auth_error_invalid_password;
      }
      if (passwordController.text != confirmPasswordController.text) {
        return LocaleKeys.auth_error_password_mismatch;
      }
    }
    return null;
  }

  Future<void> register() async {
    final validationError = validateCurrentStep();
    if (validationError != null) {
      emit(AuthFailure(validationError));
      return;
    }

    emit(AuthLoading());

    try {
      final dobStr = selectedDob != null
          ? "${selectedDob!.year}-${selectedDob!.month.toString().padLeft(2, '0')}-${selectedDob!.day.toString().padLeft(2, '0')}"
          : "";

      final request = RegisterRequestModel(
        fullName: fullNameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        role: selectedRole,
        phoneNumber: phoneController.text.trim(),
        gender: selectedGender ?? 'male',
        dateOfBirth: dobStr,
        height: double.tryParse(heightController.text.trim()),
        weight: double.tryParse(weightController.text.trim()),
        image: profileImagePath,
      );

      final response = await repository.register(request);

      // Always log registration and send pending approval to admin
      await AdminLogService.instance.logUserRegistration(
        userId: response.id,
        email: response.email,
        fullName: response.fullName,
        role: response.role,
      );
      await AdminLogService.instance.sendPendingApproval(
        userId: response.id,
        email: response.email,
        fullName: response.fullName,
        role: response.role,
        profileImage: profileImagePath,
      );

      // Emit NeedVerification to inform user they must wait for admin approval
      emit(AuthNeedVerification());
    } catch (e) {
      await AdminLogService.instance.logError(
        type: 'register_error',
        userId: '',
        email: emailController.text.trim(),
        error: e.toString(),
      );
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> login() async {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(emailController.text.trim())) {
      emit(AuthFailure(LocaleKeys.auth_error_invalid_email));
      return;
    }
    if (passwordController.text.length < 6) {
      emit(AuthFailure(LocaleKeys.auth_error_invalid_password));
      return;
    }

    emit(AuthLoading());

    try {
      final request = LoginRequestModel(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      final response = await repository.login(request);
      if (response.isVerified == true) {
        // Log successful login
        await AdminLogService.instance.logUserLogin(
          userId: response.id,
          email: response.email,
          role: response.role,
        );
        emit(AuthSuccess(response));
      } else {
        emit(AuthNeedVerification());
      }
    } catch (e) {
      await AdminLogService.instance.logError(
        type: 'login_error',
        userId: '',
        email: emailController.text.trim(),
        error: e.toString(),
      );
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> resetPassword() async {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(emailController.text.trim())) {
      emit(AuthFailure(LocaleKeys.auth_error_invalid_email));
      return;
    }
    emit(AuthLoading());
    try {
      await repository.reresetPassword(emailController.text.trim());
      emit(AuthResetPasswordSuccessfully());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  @override
  Future<void> close() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    heightController.dispose();
    weightController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    return super.close();
  }
}
