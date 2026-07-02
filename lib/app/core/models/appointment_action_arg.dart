import 'package:avo_app/app/core/models/appointment_model.dart';
import 'package:avo_app/app/core/models/patient_model.dart';

class AppointmentActionArgs {
  final PatientModel patient;
  final String appointmentId;
  final String appointmentStatus;

  const AppointmentActionArgs({
    required this.patient,
    required this.appointmentId,
    required this.appointmentStatus,
  });
}
