import 'package:avo_app/app/core/models/appointment_card_model.dart';
import 'package:avo_app/app/features/appointment/models/appointment_model.dart';

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
  Future<void> createAppointment(
    AppointmentModel appointment,
  );

  Future<void> completeAppointment(
    AppointmentModel appointment,
  );

  Future<void> cancelAppointment(
    String appointmentId,
  );

  Future<void> updateAppointmentDetails({
    required String appointmentId,
    DateTime? appointmentDate,
    String? timeStart,
    String? timeEnd,
    String? room,
    String? title,
  });

  Future<void> confirmAppointment(
    AppointmentModel appointment,
  );

  Future<void> rejectAppointment(
    AppointmentModel appointment,
  );
}
