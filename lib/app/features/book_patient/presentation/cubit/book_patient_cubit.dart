import 'package:avo_app/app/core/models/appointment_model.dart';
import 'package:avo_app/app/core/models/schedule_model.dart';
import 'package:avo_app/app/core/utils/date_calculator.dart';
import 'package:avo_app/app/features/book_patient/domain/book_patient_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'book_patient_state.dart';

class BookPatientCubit extends Cubit<BookPatientState> {
  final BookPatientRepository _repository;

  BookPatientCubit({required BookPatientRepository repository})
      : _repository = repository,
        super(BookPatientInitial());

  Future<void> loadDoctor(String doctorId) async {
    if (isClosed) return;
    emit(BookPatientLoading());
    try {
      final doctor = await _repository.getDoctorDetails(doctorId);
      final schedules = await _repository.getDoctorSchedules(doctorId);
      if (isClosed) return;
      emit(BookPatientLoaded(
        doctor: doctor,
        schedules: schedules,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(BookPatientError("Failed to load doctor details: ${e.toString()}"));
    }
  }

  void selectSchedule(ScheduleModel schedule) {
    if (isClosed) return;
    final currentState = state;
    if (currentState is BookPatientLoaded) {
      emit(currentState.copyWith(selectedSchedule: schedule));
    }
  }

  Future<void> bookAppointment({
    required String patientId,
    required String patientName,
  }) async {
    if (isClosed) return;
    final currentState = state;
    if (currentState is BookPatientLoaded) {
      final schedule = currentState.selectedSchedule;
      if (schedule == null) {
        if (isClosed) return;
        emit(BookPatientBookingError("Please select a schedule slot first"));
        emit(currentState);
        return;
      }

      if (isClosed) return;
      emit(BookPatientBookingLoading());
      try {
        final appointmentDate = calculateNextDateForWeekday(schedule.day);

        final appointment = AppointmentModel(
          id: '',
          doctorId: currentState.doctor.id,
          patientId: patientId,
          patientName: patientName,
          doctorName: currentState.doctor.name,
          date: appointmentDate,
          day: schedule.day,
          startTime: schedule.startTime,
          endTime: schedule.endTime,
          status: 'pending',
        );

        await _repository.bookAppointment(appointment);
        if (isClosed) return;
        emit(BookPatientBookingSuccess());
        await loadDoctor(currentState.doctor.id);
      } catch (e) {
        if (isClosed) return;
        emit(BookPatientBookingError("Booking failed: ${e.toString()}"));
        emit(currentState);
      }
    }
  }
}