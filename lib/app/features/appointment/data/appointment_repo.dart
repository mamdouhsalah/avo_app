import 'package:avo_app/app/core/models/appointment_card_model.dart';
import 'package:avo_app/app/features/appointment/models/appointment.dart';

abstract class AppointmentRepo {
  /// get all appointment : called once then filtered
  /// different behaviour based on role
  //TODO : make this work with doctor too
  Future<List<AppointmentCardModel>> getAllAppointments();

  /// patient methods
  /// upcomming , canceled , completed , favourite will be handled in cubit
  Future<void> setFavourite(String appointmentId);

  /// rate only after completing appointment
  Future<void> rate(String appointmentId, double rate);

  Future<void> bookAppointment(String appointmentId);

  /// Doctor methods
  /// create update delete complete appointment
  Future<String> createAppointment(
    // returns new app id
    AppointmentModel appointment,
  );

  Future<void> completeAppointment(
    String appointmentId,
  );

  Future<void> cancelAppointment(
    String appointmentId,
  );

  Future<void> updateAppointmentDetails(AppointmentModel updatedAppointment);

  Future<void> confirmAppointment(
    String appointmentId,
  );

  Future<void> rejectAppointment(
    String appointmentId,
  );

  Future<void> deleteAppointment(
    String appointmentId,
  );
}
