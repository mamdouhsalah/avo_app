import 'package:avo_app/app/core/constants/database_paths.dart';
import 'package:avo_app/app/core/models/appointment_model.dart';
import 'package:avo_app/app/core/models/doctor_model.dart';
import 'package:avo_app/app/core/models/schedule_model.dart';
import 'package:avo_app/app/core/services/remote/firebase_consumer.dart';
import 'package:avo_app/app/features/book_patient/domain/book_patient_repository.dart';
import 'package:avo_app/app/features/notification/services/notification_sender_service.dart';

class BookPatientRepositoryImpl implements BookPatientRepository {
  final FirebaseConsumer _consumer;

  BookPatientRepositoryImpl({required FirebaseConsumer consumer}) : _consumer = consumer;

  @override
  Future<DoctorModel> getDoctorDetails(String doctorId) async {
    return await _consumer.get(
      '${DatabasePaths.doctors}/$doctorId',
      fromJson: (json) => DoctorModel.fromJsonWithSchedules(json),
    );
  }

  @override
  Future<List<ScheduleModel>> getDoctorSchedules(String doctorId) async {
    try {
      return await _consumer.getList(
        'doctors/$doctorId/schedules',
        fromJson: (json) => ScheduleModel.fromJson(json),
      );
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> bookAppointment(AppointmentModel appointment) async {
    final data = appointment.toJson();
    final String appointmentId = await _consumer.push(
      DatabasePaths.appointments,
      data: data,
    );
    data['id'] = appointmentId;
    await _consumer.update(
      '${DatabasePaths.appointments}/$appointmentId',
      data: data,
    );

    try {
      final docData = await _consumer.get('users/${appointment.doctorId}', fromJson: (json) => json);
      if (docData is Map) {
        final fcmToken = docData['fcmToken']?.toString();
        if (fcmToken != null && fcmToken.isNotEmpty) {
          await NotificationSenderService.sendNotification(
            fcmToken: fcmToken,
            title: 'New Appointment',
            body: '${appointment.patientName} has booked an appointment with you!',
            chatId: '',
            senderId: appointment.patientId,
          );
        }
      }
    } catch (e) {
      // Ignore notification errors
    }
  }
}
