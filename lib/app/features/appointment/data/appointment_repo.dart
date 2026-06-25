import 'package:avo_app/app/features/appointment/models/appointment_model.dart';

abstract class AppointmentRepo {

  Future<String> getCurrentUserRole();

  /// get all appointment : called once then filtered
  /// different behaviour based on role
  //TODO : make this work with doctor too
  Future<List<AppointmentModel>> getAllAppointments();

  /// patient methods
  /// upcomming , canceled , completed , favourite will be handled in cubit
  Future<void> setFavourite(String appointmentId);

  /// rate only after completing appointment
  Future<void> rate(String appointmentId, double rate);

  /// Doctor methods
  /// create update delete complete appointment
  Future<void> createAppointment(
    AppointmentModel appointment,
  );

  Future<void> updateAppointment(
    AppointmentModel appointment,
  );

  Future<void> completeAppointment(
    String appointmentId,
  );

  Future<void> cancelAppointment(
    String appointmentId,
  );
}
