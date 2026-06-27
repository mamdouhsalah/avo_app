import 'package:avo_app/app/core/constants/database_paths.dart';
import 'package:avo_app/app/core/models/appointment_model.dart';
import 'package:avo_app/app/core/models/lab_result_model.dart';
import 'package:avo_app/app/core/models/patient_model.dart';
import 'package:avo_app/app/core/models/schedule_model.dart';
import 'package:avo_app/app/core/services/remote/firebase_consumer.dart';
import 'package:avo_app/app/core/services/remote/firebase_query_params.dart';
import 'package:avo_app/app/features/doctor/data/doctor_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorRepositoryImpl implements DoctorRepository {
  final FirebaseConsumer _consumer;
  final FirebaseAuth _firebaseAuth;

  DoctorRepositoryImpl(
      {required FirebaseConsumer consumer, FirebaseAuth? firebaseAuth})
      : _consumer = consumer,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Stream<List<AppointmentModel>> streamDoctorAppointments(String doctorId) {
    return _consumer.streamList(
      DatabasePaths.appointments,
      fromJson: (json) => AppointmentModel.fromJson(json),
      queryParams: FirebaseQueryParams(
        orderByChild: 'doctorId',
        equalTo: doctorId,
      ),
    );
  }

  @override
  Future<List<PatientModel>> getDoctorPatients(String doctorId) async {
    try {
      // Get appointments for this doctor
      final appointments = await _consumer.getList(
        DatabasePaths.appointments,
        fromJson: (json) => AppointmentModel.fromJson(json),
        queryParams: FirebaseQueryParams(
          orderByChild: 'doctorId',
          equalTo: doctorId,
        ),
      );

      // Extract unique patient IDs (flat string field)
      final patientIds = appointments
          .map((e) => e.patientId)
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      final List<PatientModel> patients = [];

      // Fetch each patient's details from users/{uid}
      for (final pid in patientIds) {
        try {
          final patient = await _consumer.get(
            '${DatabasePaths.users}/$pid',
            fromJson: (json) => PatientModel.fromJson(json),
          );
          if (patient.role == 'patient') {
            patients.add(patient);
          }
        } catch (e) {
          // Patient not found or other error, skip
        }
      }
      return patients;
    } catch (e) {
      // If appointments node doesn't exist yet, return empty list
      return [];
    }
  }

  @override
  Future<List<LabResultModel>> getLabResults(String patientId) async {
    try {
      return await _consumer.getList(
        DatabasePaths.reports,
        fromJson: (json) => LabResultModel.fromJson(json),
        queryParams: FirebaseQueryParams(
          orderByChild: 'patientId',
          equalTo: patientId,
        ),
      );
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> addLabResult(LabResultModel result) async {
    await _consumer.push(DatabasePaths.reports, data: result.toJson());
  }

  @override
  Future<String> addDoctorSchedule(ScheduleModel schedule) async {
    final String doctorId = _firebaseAuth.currentUser?.uid ?? '';
    
    String doctorName = '';
    String doctorImage = '';
    try {
      final docData = await _consumer.get(
        '${DatabasePaths.users}/$doctorId',
        fromJson: (json) => json,
      );
      doctorName = docData['name']?.toString() ?? docData['full_name']?.toString() ?? '';
      doctorImage = docData['imageUrl']?.toString() ?? docData['image']?.toString() ?? '';
    } catch (_) {}

    final data = schedule.toJson();
    data['doctorName'] = doctorName;
    data['doctorImage'] = doctorImage;

    return await _consumer.push(
      DatabasePaths.doctorSchedule(doctorId),
      data: data,
    );
  }

  @override
  Future<void> updateDoctorSchedule(ScheduleModel schedule) async {
    final String doctorId = _firebaseAuth.currentUser?.uid ?? '';
    
    String doctorName = '';
    String doctorImage = '';
    try {
      final docData = await _consumer.get(
        '${DatabasePaths.users}/$doctorId',
        fromJson: (json) => json,
      );
      doctorName = docData['name']?.toString() ?? docData['full_name']?.toString() ?? '';
      doctorImage = docData['imageUrl']?.toString() ?? docData['image']?.toString() ?? '';
    } catch (_) {}

    final data = schedule.toJson();
    data['doctorName'] = doctorName;
    data['doctorImage'] = doctorImage;

    await _consumer.update(
      '${DatabasePaths.doctorSchedule(doctorId)}/${schedule.id}',
      data: data,
    );
  }

  @override
  Future<void> deleteDoctorSchedule(String scheduleId) async {
    final String doctorId = _firebaseAuth.currentUser?.uid ?? '';
    await _consumer.delete(
      '${DatabasePaths.doctorSchedule(doctorId)}/$scheduleId',
    );
  }

  @override
  Future<List<ScheduleModel>> getDoctorSchedules() async {
    final String doctorId = _firebaseAuth.currentUser?.uid ?? '';
    try {
      return await _consumer.getList(
        DatabasePaths.doctorSchedule(doctorId),
        fromJson: (json) => ScheduleModel.fromJson(json),
      );
    } catch (e) {
      return [];
    }
  }
}
