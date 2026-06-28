import 'package:avo_app/app/core/models/schedule_model.dart';

abstract class AddDoctorState {}

class AddDoctorInitial extends AddDoctorState {}

class AddDoctorScheduleLoading extends AddDoctorState {}

class AddDoctorScheduleLoaded extends AddDoctorState {
  final List<ScheduleModel> schedules;
  AddDoctorScheduleLoaded(this.schedules);
}

class AddDoctorScheduleError extends AddDoctorState {
  final String message;
  AddDoctorScheduleError(this.message);
}

class AddDoctorScheduleActionSuccess extends AddDoctorState {
  final String message;
  AddDoctorScheduleActionSuccess(this.message);
}