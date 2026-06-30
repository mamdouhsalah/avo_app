import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:avo_app/app/features/doctor/data/doctor_repository.dart';
import 'doctor_rating_state.dart';

class DoctorRatingCubit extends Cubit<DoctorRatingState> {
  final DoctorRepository _repository;

  DoctorRatingCubit({required DoctorRepository repository})
      : _repository = repository,
        super(const DoctorRatingInitial());

  Future<void> rateDoctor(String doctorId, double patientRating) async {
    if (isClosed) return;
    emit(const DoctorRatingLoading());
    try {
      final double newDoctorRate = await _repository.rateDoctor(doctorId, patientRating);
      if (isClosed) return;
      emit(DoctorRatingSuccess(newDoctorRate));
    } catch (e) {
      if (isClosed) return;
      emit(DoctorRatingError(e.toString()));
    }
  }
}