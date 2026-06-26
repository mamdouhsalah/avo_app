// a UI model used to connect patient and doctor via appointment ids
import 'package:avo_app/app/core/models/doctor_model.dart';
import 'package:avo_app/app/core/models/user_profile_model.dart';
import 'package:avo_app/app/features/appointment/models/appointment_model.dart';

class AppointmentCardModel {
  final AppointmentModel appointment;

  final DoctorModel doctor;

// represent user in firebase 
// null because no guarantee to be exist 
  final UserProfileModel? patient;

  AppointmentCardModel({
    required this.appointment,
    required this.doctor,
    this.patient,
  });
}