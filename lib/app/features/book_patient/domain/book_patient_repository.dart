import 'package:avo_app/app/core/models/appointment_model.dart';
import 'package:avo_app/app/core/models/schedule_model.dart';
import 'package:avo_app/app/core/models/doctor_model.dart';

abstract class BookPatientRepository {
  Future<DoctorModel> getDoctorDetails(String doctorId);
  Future<List<ScheduleModel>> getDoctorSchedules(String doctorId);
  Future<void> bookAppointment(AppointmentModel appointment);
}
