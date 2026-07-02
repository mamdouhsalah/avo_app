import 'package:avo_app/app/core/models/appointment_card_model.dart';
import 'package:avo_app/app/core/models/appointment_model.dart';

abstract class AppointmentRepo {
  /// get all appointment : called once then filtered
  /// different behaviour based on role
  //TODO : make this work with doctor too
  Future<List<AppointmentCardModel>> getAllAppointments();

  /// patient methods
  /// upcomming , canceled , completed , favourite will be handled in cubit

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

  Future<void> deleteAppointment(
    String appointmentId,
  );

  Future<void> setRated(String appointmentId);

  Future<void> setPatientRating(
    String appointmentId,
    double rating,
  );
}
