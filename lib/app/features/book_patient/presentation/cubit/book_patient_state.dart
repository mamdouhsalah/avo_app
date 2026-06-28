import 'package:avo_app/app/core/models/doctor_model.dart';
import 'package:avo_app/app/core/models/schedule_model.dart';

abstract class BookPatientState {}

class BookPatientInitial extends BookPatientState {}

class BookPatientLoading extends BookPatientState {}

class BookPatientLoaded extends BookPatientState {
  final DoctorModel doctor;
  final List<ScheduleModel> schedules;
  final ScheduleModel? selectedSchedule;

  BookPatientLoaded({
    required this.doctor,
    required this.schedules,
    this.selectedSchedule,
  });

  BookPatientLoaded copyWith({
    DoctorModel? doctor,
    List<ScheduleModel>? schedules,
    ScheduleModel? selectedSchedule,
    bool clearSelectedSchedule = false,
  }) {
    return BookPatientLoaded(
      doctor: doctor ?? this.doctor,
      schedules: schedules ?? this.schedules,
      selectedSchedule: clearSelectedSchedule ? null : (selectedSchedule ?? this.selectedSchedule),
    );
  }
}

class BookPatientError extends BookPatientState {
  final String message;
  BookPatientError(this.message);
}

class BookPatientBookingLoading extends BookPatientState {}

class BookPatientBookingSuccess extends BookPatientState {}

class BookPatientBookingError extends BookPatientState {
  final String message;
  BookPatientBookingError(this.message);
}
