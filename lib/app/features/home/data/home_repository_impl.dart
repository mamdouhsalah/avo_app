import 'package:avo_app/app/core/constants/database_paths.dart';
import 'package:avo_app/app/core/models/appointment_model.dart';
import 'package:avo_app/app/core/models/catogery_model.dart';
import 'package:avo_app/app/core/models/doctor_model.dart';
import 'package:avo_app/app/core/models/medicine_model.dart';
import 'package:avo_app/app/core/models/pharmacy_model.dart';
import 'package:avo_app/app/core/services/remote/firebase_consumer.dart';
import 'package:avo_app/app/core/services/remote/firebase_query_params.dart';
import 'package:avo_app/app/features/home/data/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final FirebaseConsumer _consumer;

  HomeRepositoryImpl({required FirebaseConsumer consumer})
      : _consumer = consumer;

  @override
  Future<List<DoctorModel>> getBestDoctors() async {
    return await _consumer.getList(DatabasePaths.doctors, fromJson: (json) => DoctorModel.fromJson(json), queryParams: FirebaseQueryParams(orderByChild: 'isBest', equalTo: true, limitToFirst: 5));
  }

  @override
  Future<List<PharmacyModel>> getBestPharmacies() async {
    return await _consumer.getList(DatabasePaths.pharmacies, fromJson: (json) => PharmacyModel.fromJson(json), queryParams: FirebaseQueryParams(orderByChild: 'rating',  limitToFirst: 5)); 
  }

  @override
  Future<List<AppointmentModel>> getAppointment(String patientId) async {
    return await _consumer.getList(DatabasePaths.appointments, fromJson: (json) => AppointmentModel.fromJson(json), queryParams: FirebaseQueryParams(orderByChild: 'patientId', equalTo: patientId));
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    return await _consumer.getList(DatabasePaths.categories, fromJson: (json) => CategoryModel.fromJson(json));
  }

  @override
  Future<List<MedicineModel>> getMedicines(String patientId) async {
    return await _consumer.getList(DatabasePaths.patientMedicines(patientId), fromJson: (json) => MedicineModel.fromJson(json));
  }
}
