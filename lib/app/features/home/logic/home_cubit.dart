import 'package:avo_app/app/core/errors/database_exception.dart';
import 'package:avo_app/app/core/models/patient_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/home_repository.dart';
import 'home_state.dart';
import '../../../core/models/appointment_model.dart';
import '../../../core/models/catogery_model.dart';
import '../../../core/models/doctor_model.dart';
import '../../../core/models/pharmacy_model.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _repository;

  HomeCubit({required HomeRepository repository}) : _repository = repository, super(HomeInitial());

  Future<void> loadDashboard(String patientId) async {
    emit(HomeLoading());

    try {
      final responses = await Future.wait([
        _repository.getPatientData(),
        _repository.getAppointment(patientId),
        _repository.getCategories(),
        _repository.getBestDoctors(),
        _repository.getBestPharmacies(),
      ]);

      emit(HomeLoaded(
        currentUser: responses[0] as PatientModel,
        appointments: responses[1] as List<AppointmentModel>,
        categories: responses[2] as List<CategoryModel>,
        bestDoctors: responses[3] as List<DoctorModel>,
        bestPharmacies: responses[4] as List<PharmacyModel>,
      ));
    } on DatabaseException catch (e) {
      emit(HomeError(e.message));
    } catch (e) {
      emit(HomeError("Failed to fetch dashboard data. Please check your connection."));
    }
  }
}