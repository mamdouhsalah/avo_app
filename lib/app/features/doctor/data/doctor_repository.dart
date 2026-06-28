import 'package:avo_app/app/core/models/appointment_model.dart';
import 'package:avo_app/app/core/models/lab_result_model.dart';
import 'package:avo_app/app/core/models/patient_model.dart';
import 'package:avo_app/app/core/models/schedule_model.dart';

abstract class DoctorRepository {
  Stream<List<AppointmentModel>> streamDoctorAppointments(String doctorId);
  Future<List<PatientModel>> getDoctorPatients(String doctorId);
  Future<List<LabResultModel>> getLabResults(String patientId);
  Future<void> addLabResult(LabResultModel result);

  // Doctor Schedules
  Future<String> addDoctorSchedule(ScheduleModel schedule);
  Future<void> updateDoctorSchedule(ScheduleModel schedule);
  Future<void> deleteDoctorSchedule(String scheduleId);
  Future<List<ScheduleModel>> getDoctorSchedules();
}
