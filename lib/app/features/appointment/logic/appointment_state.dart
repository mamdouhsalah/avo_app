import 'package:avo_app/app/core/models/appointment_card_model.dart';

abstract class AppointmentState {
  const AppointmentState();
}

class AppointmentInitial extends AppointmentState {
  const AppointmentInitial();
}

class AppointmentLoading extends AppointmentState {
  const AppointmentLoading();
}

class AppointmentLoaded extends AppointmentState {
  final List<AppointmentCardModel> appointments;

  const AppointmentLoaded(this.appointments);
}

class AppointmentError extends AppointmentState {
  final String message;

  const AppointmentError(this.message);
}