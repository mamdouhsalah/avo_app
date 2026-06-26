import 'package:avo_app/app/core/models/patient_model.dart';
import 'package:flutter/foundation.dart';
import '../../../core/models/appointment_model.dart';
import '../../../core/models/catogery_model.dart';
import '../../../core/models/doctor_model.dart';
import '../../../core/models/pharmacy_model.dart';

@immutable
abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final PatientModel currentUser;
  final List<AppointmentModel> appointments;
  final List<CategoryModel> categories;
  final List<DoctorModel> bestDoctors;
  final List<PharmacyModel> bestPharmacies;

  HomeLoaded({
    required this.currentUser,
    required this.appointments,
    required this.categories,
    required this.bestDoctors,
    required this.bestPharmacies,
  });
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}