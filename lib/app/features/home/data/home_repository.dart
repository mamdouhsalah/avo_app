import 'package:avo_app/app/core/models/appointment_model.dart';
import 'package:avo_app/app/core/models/catogery_model.dart';
import 'package:avo_app/app/core/models/doctor_model.dart';
import 'package:avo_app/app/core/models/medicine_model.dart';
import 'package:avo_app/app/core/models/patient_model.dart';
import 'package:avo_app/app/core/models/pharmacy_model.dart';

abstract class HomeRepository {
  Future<PatientModel> getPatientData();
  Future<List<DoctorModel>> getBestDoctors();
  Future<List<PharmacyModel>> getBestPharmacies();
  Future<List<AppointmentModel>> getAppointment(String patientId);
  Future<List<CategoryModel>> getCategories();
}