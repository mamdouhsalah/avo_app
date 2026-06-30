import 'package:avo_app/app/core/constants/database_paths.dart';
import 'package:avo_app/app/core/errors/database_exception.dart';
import 'package:avo_app/app/core/models/appointment_card_model.dart';
import 'package:avo_app/app/core/models/appointment_model.dart';
import 'package:avo_app/app/core/models/current_user.dart';
import 'package:avo_app/app/core/models/patient_model.dart';
import 'package:avo_app/app/core/models/user_profile_model.dart';
import 'package:avo_app/app/core/models/user_role.dart';
import 'package:avo_app/app/core/services/remote/firebase_consumer.dart';
import 'package:avo_app/app/core/services/remote/firebase_query_params.dart';
import 'package:avo_app/app/features/appointment/data/appointment_repo.dart';
import 'package:avo_app/app/features/doctor/data/doctor_repository.dart';
import 'package:avo_app/app/features/profile/data/profile_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AppointmentRepoImp implements AppointmentRepo {
  final FirebaseConsumer _consumer;
  final FirebaseAuth _firebaseAuth; // for current user
  final DoctorRepository _doctorRepository;
  final ProfileRepository _patientRepository; // feels misleading but ...

  AppointmentRepoImp(
      {required FirebaseConsumer consumer,
      FirebaseAuth? firebaseAuth,
      required DoctorRepository doctorRepository,
      required ProfileRepository patientRepository})
      : _consumer = consumer,
        _doctorRepository = doctorRepository,
        _patientRepository = patientRepository,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  /// helper functions

  Future<List<AppointmentCardModel>> _buildAppointmentCards(
    List<AppointmentModel> appointments,
  ) async {
    final List<AppointmentCardModel> cards = [];

    for (final appointment in appointments) {
      final doctor =
          await _doctorRepository.getDoctorById(appointment.doctorId);

      PatientModel patient =
          await _patientRepository.getUserIfPatientById(appointment.patientId);

      cards.add(
        AppointmentCardModel(
          appointment: appointment,
          doctor: doctor,
          patient: patient,
        ),
      );
    }

    return cards;
  }

  Future<AppointmentModel> _getAppointmentById(String appointmentId) async {
    try {
      final AppointmentModel appointment = await _consumer
          .get<AppointmentModel>('${DatabasePaths.appointments}/$appointmentId',
              fromJson: (json) => AppointmentModel.fromJson(json));
      return appointment;
    } catch (e) {
      throw DatabaseException(e.toString(), 'failed-to-load-appointment');
    }
  }

// determines doctor / patient
  Future<CurrentUser> _getCurrentUser() async {
    try {
      final currentUser = _firebaseAuth.currentUser;

      if (currentUser == null) {
        throw DatabaseException(
          'User not authenticated',
          'unauthenticated',
        );
      }

      final uid = currentUser.uid;

      final UserProfileModel user = await _consumer.get<UserProfileModel>(
        '${DatabasePaths.users}/$uid',
        fromJson: (json) => UserProfileModel.fromJson(json),
      );

      return CurrentUser(uid: uid, role: user.role);
    } catch (e) {
      throw DatabaseException(
        e.toString(),
        'failed-to-get-current-user',
      );
    }
  }

  /// get all appointment : called once then filtered
  /// different behaviour based on role
  //TODO : connect getAppointment to doctor

  Future<List<AppointmentModel>> _getPatientAppointments() async {
    try {
      final CurrentUser user = await _getCurrentUser();
      final uid = user.uid;
      final List<AppointmentModel> appointments =
          await _consumer.getList<AppointmentModel>(
        '${DatabasePaths.appointments}',
        fromJson: (json) => AppointmentModel.fromJson(json),
        queryParams: FirebaseQueryParams(
          orderByChild: 'patientId',
          equalTo: uid,
        ),
      );
      return appointments;
    } catch (e) {
      throw DatabaseException(
          e.toString(), 'failed-to-get-patient-appointments');
    }
  }

  Future<List<AppointmentModel>> _getDoctorAppointments() async {
    try {
      final CurrentUser user = await _getCurrentUser();
      final uid = user.uid;
      final List<AppointmentModel> appointments =
          await _consumer.getList<AppointmentModel>(
        '${DatabasePaths.appointments}',
        fromJson: (json) => AppointmentModel.fromJson(json),
        queryParams: FirebaseQueryParams(
          orderByChild: 'doctorId',
          equalTo: uid,
        ),
      );
      return appointments;
    } catch (e) {
      throw DatabaseException(
          e.toString(), 'failed-to-get-doctor-appointments');
    }
  }

  @override
  Future<List<AppointmentCardModel>> getAllAppointments() async {
    try {
      final CurrentUser user = await _getCurrentUser();

      final List<AppointmentModel> appointments;

      switch (user.role) {
        case UserRole.patient:
          appointments = await _getPatientAppointments();
          break;

        case UserRole.doctor:
        default:
          appointments = await _getDoctorAppointments();
          break;
      }

      return await _buildAppointmentCards(appointments);
    } catch (e) {
      throw DatabaseException(
        e.toString(),
        'failed-to-get-user-appointments',
      );
    }
  }

  // set as rated : prevent double rating
  @override
  Future<void> setRated(String appointmentId) async {
    try {
      await _consumer.update(
        'appointments/$appointmentId',
        data: {
          'isRated': true,
        },
      );
    } catch (e) {
      throw DatabaseException(e.toString(), "failed to set rate");
    }
  }

  @override
  Future<void> setPatientRating(
    String appointmentId,
    double rating,
  ) async {
    try {
      await _consumer.update(
        'appointments/$appointmentId',
        data: {
          'patientRating': rating,
        },
      );
    } catch (e) {
      throw DatabaseException(e.toString(), "failed to set patient rating");
    }
  }

  /// patient methods
  /// TODO : upcomming , canceled , completed , favourite will be handled in cubit

  /// Doctor methods
  @override
  Future<void> updateAppointmentDetails(
    AppointmentModel updatedAppointment,
  ) async {
    try {
      final user = await _getCurrentUser();

      if (user.role != UserRole.doctor) {
        throw DatabaseException(
          'Only doctors can update appointments',
          'permission-denied',
        );
      }

      await _consumer.update(
        '${DatabasePaths.appointments}/${updatedAppointment.id}',
        data: updatedAppointment.toJson(),
      );
    } catch (e) {
      throw DatabaseException(
        e.toString(),
        'failed-to-update-appointment',
      );
    }
  }

  @override
  Future<void> completeAppointment(
    String appointmentId,
  ) async {
    try {
      final user = await _getCurrentUser();
      // only doctor can make appointment completed
      if (user.role != UserRole.doctor) {
        throw DatabaseException(
          'Only doctors can complete appointments',
          'permission-denied',
        );
      }
      final AppointmentModel appointment =
          await _getAppointmentById(appointmentId);
      if (appointment.status !=
              AppointmentStatus.confirmed // must be upcoming first
          ) {
        throw DatabaseException(
          'Only upcoming appointments can be completed',
          'invalid-status',
        );
      }

      await _consumer.update(
        '${DatabasePaths.appointments}/${appointment.id}',
        data: {
          'status': AppointmentStatus.completed,
        },
      );
    } catch (e) {
      throw DatabaseException(
        e.toString(),
        'failed-to-complete-appointment',
      );
    }
  }

  @override

  ///TODO : later caceled automatically if appointment date == now and it is pending
  Future<void> cancelAppointment(String appointmentId) async {
    // both doctor and patient can cancel an appointment
    try {
      /// to know the appointment was canceled by whome for future statistics
      CurrentUser currentUser = await _getCurrentUser();
      final AppointmentModel appointment =
          await _getAppointmentById(appointmentId);
      if (appointment.status == AppointmentStatus.completed) {
        throw DatabaseException(
          'Completed appointments cannot be cancelled',
          'appointment-already-completed',
        );
      }

      if (appointment.status == AppointmentStatus.canceled) {
        throw DatabaseException(
          'Appointment already cancelled',
          'appointment-already-cancelled',
        );
      }

      await _consumer.update(
        '${DatabasePaths.appointments}/${appointment.id}',
        data: {
          'status': AppointmentStatus.canceled,
          'canceledBy': currentUser.uid
        },
      );
    } catch (e) {
      throw DatabaseException(
        e.toString(),
        'failed-to-cancel-appointment',
      );
    }
  }

  @override
  Future<void> confirmAppointment(
    String appointmentId,
  ) async {
    try {
      final CurrentUser user = await _getCurrentUser();
      final AppointmentModel appointment =
          await _getAppointmentById(appointmentId);
// feel extra thing to do here!!!!
      if (user.role != UserRole.doctor) {
        throw DatabaseException(
          'Only doctors can confirm appointments',
          'permission-denied',
        );
      }

      if ( // must be pending first
          appointment.status != AppointmentStatus.pending) {
        throw DatabaseException(
          'Appointment is not pending',
          'invalid-status',
        );
      }

      await _consumer.update(
        '${DatabasePaths.appointments}/${appointment.id}',
        data: {
          'status': AppointmentStatus.confirmed,
        },
      );
    } catch (e) {
      throw DatabaseException(
        e.toString(),
        'failed-to-confirm-appointment',
      );
    }
  }

  @override
  Future<void> deleteAppointment(
    String appointmentId,
  ) async {
    try {
      final CurrentUser currentUser = await _getCurrentUser();
      // firebase will handle it even it was not exist
      if (currentUser.role == UserRole.doctor) {
        await _consumer.delete(
          '${DatabasePaths.appointments}/$appointmentId',
        );
      }
    } catch (e) {
      throw DatabaseException(
        e.toString(),
        'failed-to-delete-appointment',
      );
    }
  }
}
