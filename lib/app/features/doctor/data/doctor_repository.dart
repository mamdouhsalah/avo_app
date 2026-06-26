import 'package:avo_app/app/core/models/appointment_model.dart';
import 'package:avo_app/app/core/models/lab_result_model.dart';
import 'package:avo_app/app/core/models/patient_model.dart';

abstract class DoctorRepository {
  Stream<List<AppointmentModel>> streamDoctorAppointments(String doctorId);
  Future<List<PatientModel>> getDoctorPatients(String doctorId);
  Future<List<LabResultModel>> getLabResults(String patientId);
  Future<void> addLabResult(LabResultModel result);
}
