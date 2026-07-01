import 'package:avo_app/app/core/models/appointment_card_model.dart';
import 'package:avo_app/app/core/models/appointment_model.dart';
import 'package:avo_app/app/features/appointment/data/appointment_repo.dart';
import 'package:avo_app/app/features/appointment/logic/appointment_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppointmentCubit extends Cubit<AppointmentState> {
  final AppointmentRepo _repository;

  AppointmentCubit(this._repository) : super(const AppointmentInitial());

  List<AppointmentCardModel> _appointments = [];

/// helper functions
void _emitLoaded() {
  emit(
    AppointmentLoaded(
      List.from(_appointments),
    ),
  );
}

// get all appointment , not loaded again until refresh or open the screen again
  Future<void> getAppointments() async {
  emit(const AppointmentLoading());

  try {
    _appointments = await _repository.getAllAppointments();

    emit(
      AppointmentLoaded(
        List.from(_appointments),
      ),
    );
  } catch (e) {
    emit(
      AppointmentError(
        e.toString(),
      ),
    );
  }
}

// getters -> all from the appointments we got first
// upcoming appointments
List<AppointmentCardModel> get upcomingAppointments =>
    _appointments.where(
      (e) =>
          e.appointment.status ==
          AppointmentStatus.confirmed,
    ).toList();

// completed appointments
List<AppointmentCardModel> get completedAppointments =>
    _appointments.where(
      (e) =>
          e.appointment.status ==
          AppointmentStatus.completed,
    ).toList();   

// canceled appointments
List<AppointmentCardModel> get canceledAppointments =>
    _appointments.where(
      (e) =>
          e.appointment.status ==
          AppointmentStatus.canceled,
    ).toList();     


/// doctor getters
// pending appointments
List<AppointmentCardModel> get pendingAppointments =>
    _appointments.where(
      (e) =>
          e.appointment.status ==
          AppointmentStatus.pending,
    ).toList();

// confirmed appointments
List<AppointmentCardModel> get confirmedAppointments =>
    _appointments.where(
      (e) =>
          e.appointment.status ==
          AppointmentStatus.confirmed,
    ).toList();    

/// counts
int get totalCount => _appointments.length;

int get pendingCount =>
    pendingAppointments.length;

int get confirmedCount =>
    confirmedAppointments.length;

int get upcomingCount =>
    upcomingAppointments.length;

int get completedCount =>
    completedAppointments.length;

int get canceledCount =>
    canceledAppointments.length;


// confirm
Future<void> confirmAppointment(String appointmentId) async {
  try {
    await _repository.confirmAppointment(appointmentId);

    final index = _appointments.indexWhere(
      (e) => e.appointment.id == appointmentId,
    );

    if (index == -1) return;

    final card = _appointments[index];

    _appointments[index] = card.copyWith(
      appointment: card.appointment.copyWith(
        status: AppointmentStatus.confirmed,
      ),
    );

    _emitLoaded();
  } catch (e) {
    emit(AppointmentError(e.toString()));
  }
}

Future<void> submitRating(
  String appointmentId,
  double rating,
) async {
  try {
    await _repository.setPatientRating(appointmentId, rating);
    await _repository.setRated(appointmentId);

    final index = _appointments.indexWhere(
      (e) => e.appointment.id == appointmentId,
    );

    if (index == -1) return;

    final card = _appointments[index];

    _appointments[index] = card.copyWith(
      appointment: card.appointment.copyWith(
        patientRating: rating,
        isRated: true,
      ),
    );

    _emitLoaded();
  } catch (e) {
    emit(AppointmentError(e.toString()));
  }
}

bool? isRated(String appointmentId) {
  final appointment = _appointments.firstWhere(
    (e) => e.appointment.id == appointmentId,
    orElse: () => throw Exception("Appointment not found"),
  );

  return appointment.appointment.isRated;
}
Future<void> completeAppointment(String appointmentId) async {
  try {
    await _repository.completeAppointment(appointmentId);

    final index = _appointments.indexWhere(
      (e) => e.appointment.id == appointmentId,
    );

    if (index == -1) return;

    final card = _appointments[index];

    _appointments[index] = card.copyWith(
      appointment: card.appointment.copyWith(
        status: AppointmentStatus.completed,
      ),
    );

    _emitLoaded();
  } catch (e) {
    emit(AppointmentError(e.toString()));
  }
}

// cancel
Future<void> cancelAppointment(String appointmentId) async {
  try {
    await _repository.cancelAppointment(appointmentId);

    final index = _appointments.indexWhere(
      (e) => e.appointment.id == appointmentId,
    );

    if (index == -1) return;

    final card = _appointments[index];

    _appointments[index] = card.copyWith(
      appointment: card.appointment.copyWith(
        status: AppointmentStatus.canceled,
      ),
    );

    _emitLoaded();
  } catch (e) {
    emit(AppointmentError(e.toString()));
  }
}


//update
Future<void> updateAppointment(
  AppointmentModel updated,
) async {
  try {
    await _repository.updateAppointmentDetails(updated);

    final index = _appointments.indexWhere(
      (e) => e.appointment.id == updated.id,
    );

    if (index == -1) return;

    _appointments[index] = _appointments[index].copyWith(
      appointment: updated,
    );

    _emitLoaded();
  } catch (e) {
    emit(AppointmentError(e.toString()));
  }
}




// delete
Future<void> deleteAppointment(
    String appointmentId,
) async {

  try {

    await _repository.deleteAppointment(
      appointmentId,
    );

    _appointments.removeWhere(
      (e) =>
          e.appointment.id ==
          appointmentId,
    );

    _emitLoaded();

  } catch (e) {

    emit(
      AppointmentError(
        e.toString(),
      ),
    );

  }

}
}
