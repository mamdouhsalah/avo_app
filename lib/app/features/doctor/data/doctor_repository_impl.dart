import 'package:avo_app/app/core/constants/database_paths.dart';
import 'package:avo_app/app/core/errors/database_exception.dart';
import 'package:avo_app/app/core/models/appointment_model.dart';
import 'package:avo_app/app/core/models/doctor_model.dart';
import 'package:avo_app/app/core/models/lab_result_model.dart';
import 'package:avo_app/app/core/models/patient_model.dart';
import 'package:avo_app/app/core/models/schedule_model.dart';
import 'package:avo_app/app/core/models/medicine_model.dart';
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
    return _consumer
        .streamList(
          DatabasePaths.appointments,
          fromJson: (json) => AppointmentModel.fromJson(json),
          queryParams: FirebaseQueryParams(
            orderByChild: 'doctorId',
            equalTo: doctorId,
          ),
        )
        .asyncMap((appointments) async {
          // Enrich each appointment with real patient name if missing
          final enriched = <AppointmentModel>[];
          for (final appt in appointments) {
            if (appt.patientName != null && appt.patientName!.isNotEmpty) {
              enriched.add(appt);
            } else {
              try {
                final patientData = await _consumer.get(
                  '${DatabasePaths.users}/${appt.patientId}',
                  fromJson: (json) => json,
                );
                final name = patientData['name']?.toString() ??
                    patientData['fullName']?.toString() ??
                    patientData['full_name']?.toString() ??
                    'Patient';
                enriched.add(appt.copyWith(patientName: name));
              } catch (_) {
                enriched.add(appt);
              }
            }
          }
          return enriched;
        });
  }

  // rate doctor, for appointment use
  @override
  Future<double> rateDoctor(
    String doctorId,
    double patientRating,
  ) async {
    try {
      final doctor = await getDoctorById(doctorId);
      final currentRating = doctor.rating;
      final currentCount = doctor.ratingCount ?? 0;

      final newCount = currentCount + 1;

      final newRating =
          ((currentRating * currentCount) + patientRating) / newCount;

      await _consumer.update(
        'doctors/$doctorId',
        data: {
          'rating': newRating,
          'ratingCount': newCount,
        },
      );
      return newRating;
    } catch (e) {
      throw DatabaseException(e.toString(), "failed to rate docto");
    }
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
  Future<void> addPrescription(String patientId, MedicineModel medicine) async {
    final path = DatabasePaths.patientMedicines(patientId);
    final firebaseId = await _consumer.push(path, data: medicine.toJson());
    await _consumer.update('$path/$firebaseId', data: {'id': firebaseId});

    if (medicine.doctorId != null) {
      try {
        final count = await getDoctorPrescriptionsCount(medicine.doctorId!);
        await _consumer.update('doctors/${medicine.doctorId}', data: {'prescriptionsCount': count + 1});
      } catch (e) {}
    }
  }

  @override
  Future<List<MedicineModel>> getPatientMedicines(String patientId) async {
    try {
      return await _consumer.getList(
        DatabasePaths.patientMedicines(patientId),
        fromJson: (json) => MedicineModel.fromJson(json),
      );
    } catch (e) {
      return [];
    }
  }

  @override
  Future<int> getDoctorPrescriptionsCount(String doctorId) async {
    try {
      final docData = await _consumer.get('doctors/$doctorId', fromJson: (json) => json);
      return (docData['prescriptionsCount'] as num?)?.toInt() ?? 0;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<int> getDoctorLabResultsCount(String doctorId) async {
    try {
      final docData = await _consumer.get('doctors/$doctorId', fromJson: (json) => json);
      return (docData['labResultsCount'] as num?)?.toInt() ?? 0;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<void> addLabResult(LabResultModel result) async {
    final firebaseId = await _consumer.push(DatabasePaths.reports, data: result.toJson());
    // Write the real Firebase-generated ID back so delete works correctly
    await _consumer.update('${DatabasePaths.reports}/$firebaseId', data: {'id': firebaseId});

    if (result.doctorId.isNotEmpty) {
      try {
        final count = await getDoctorLabResultsCount(result.doctorId);
        await _consumer.update('doctors/${result.doctorId}', data: {'labResultsCount': count + 1});
      } catch (e) {}
    }
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
      doctorName = docData['name']?.toString() ??
          docData['fullName']?.toString() ??
          docData['full_name']?.toString() ??
          '';
      doctorImage =
          docData['imageUrl']?.toString() ?? docData['image']?.toString() ?? '';
    } catch (_) {}

    final data = schedule.toJson();
    data['doctorName'] = doctorName;
    data['doctorImage'] = doctorImage;

    final String scheduleId = await _consumer.push(
      'users/$doctorId/schedules',
      data: data,
    );

    data['id'] = scheduleId;
    await _consumer.update('users/$doctorId/schedules/$scheduleId', data: data);
    await _consumer.update('doctors/$doctorId/schedules/$scheduleId',
        data: data);

    return scheduleId;
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
      doctorName = docData['name']?.toString() ??
          docData['fullName']?.toString() ??
          docData['full_name']?.toString() ??
          '';
      doctorImage =
          docData['imageUrl']?.toString() ?? docData['image']?.toString() ?? '';
    } catch (_) {}

    final data = schedule.toJson();
    data['doctorName'] = doctorName;
    data['doctorImage'] = doctorImage;

    await _consumer.update(
      'users/$doctorId/schedules/${schedule.id}',
      data: data,
    );
    await _consumer.update(
      'doctors/$doctorId/schedules/${schedule.id}',
      data: data,
    );
  }

  @override
  Future<void> deleteDoctorSchedule(String scheduleId) async {
    final String doctorId = _firebaseAuth.currentUser?.uid ?? '';
    await _consumer.delete('users/$doctorId/schedules/$scheduleId');
    await _consumer.delete('doctors/$doctorId/schedules/$scheduleId');
  }

  @override
  Future<List<ScheduleModel>> getDoctorSchedules() async {
    final String doctorId = _firebaseAuth.currentUser?.uid ?? '';
    try {
      return await _consumer.getList(
        'users/$doctorId/schedules',
        fromJson: (json) => ScheduleModel.fromJson(json),
      );
    } catch (e) {
      return [];
    }
  }

  @override
  // doctor id will get it from appointment
  Future<DoctorModel> getDoctorById(
    String doctorId,
  ) async {
    try {
      return await _consumer.get<DoctorModel>(
        'doctors/$doctorId',
        fromJson: (json) => DoctorModel.fromJson(json),
      );
    } catch (e) {
      throw DatabaseException(e.toString(), 'doctor not exist');
    }
  }
}
