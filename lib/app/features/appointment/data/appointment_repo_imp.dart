import 'package:avo_app/app/core/constants/database_paths.dart';
import 'package:avo_app/app/core/errors/database_exception.dart';
import 'package:avo_app/app/core/models/current_user.dart';
import 'package:avo_app/app/core/models/user_profile_model.dart';
import 'package:avo_app/app/core/services/remote/firebase_consumer.dart';
import 'package:avo_app/app/core/services/remote/firebase_query_params.dart';
import 'package:avo_app/app/features/appointment/data/appointment_repo.dart';
import 'package:avo_app/app/features/appointment/models/appointment_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppointmentRepoImp implements AppointmentRepo {
  final FirebaseConsumer _consumer;
  final FirebaseAuth _firebaseAuth; // for current user

  AppointmentRepoImp({
    required FirebaseConsumer consumer,
    FirebaseAuth? firebaseAuth,
  })  : _consumer = consumer,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Future<AppointmentModel> _getAppointmentById(String appointmentId) async {
    try {
      final AppointmentModel appointment = await _consumer
          .get<AppointmentModel>('${DatabasePaths.appointments}/$appointmentId',
              fromJson: AppointmentModel.fromJson);
      return appointment;
    } catch (e) {
      throw DatabaseException(e.toString(), 'failed-to-load-appointment');
    }
  }

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
        fromJson: UserProfileModel.fromJson,
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
        fromJson: AppointmentModel.fromJson,
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
        fromJson: AppointmentModel.fromJson,
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
  Future<List<AppointmentModel>> getAllAppointments() async {
    try {
      final CurrentUser user = await _getCurrentUser();
      switch (user.role) {
        case 'patient':
          return await _getPatientAppointments();
        default:
          return await _getDoctorAppointments();
      }
    } catch (e) {
      throw DatabaseException(e.toString(), 'failed-to-get-user-appointments');
    }
  }

  /// patient methods
  /// upcomming , canceled , completed , favourite will be handled in cubit
  @override
  Future<void> setFavourite(String appointmentId) async {
    try {
      // updating based on appointmentId not based on the isFav from ui
      final appointment = await _getAppointmentById(appointmentId);
      await _consumer.update('${DatabasePaths.appointments}/',
          data: {'isFavourite': !appointment.isFavorite});
    } catch (e) {
      throw DatabaseException(e.toString(),
          'failed-to-set-appointment-$appointmentId-as-favourite-or-appointment-not-found');
    }
  }

  /// rate only after completing appointment
  @override
  Future<void> rate(String appointmentId, double rate) async {
    try {
      await _consumer.update('${DatabasePaths.appointments}/$appointmentId',
          data: {'rate': rate});
    } catch (e) {
      throw DatabaseException(
          e.toString(), 'failed-to-rate-or-appointment-not-found');
    }
  }

  /// Doctor methods
  /// create update delete complete appointment
  @override
  Future<void> createAppointment(
    AppointmentModel appointment,
  ) async {
    try {
      final CurrentUser user = await _getCurrentUser();
      if (user.role == 'doctor') {
        // 1. Generate the ID locally (0 network cost, completely offline)
        final String? generatedId =
            await _consumer.getRefrence(path: DatabasePaths.appointments);
        final doctorId = user.uid;
        // suppose that the doctor will create the appointment and still witout patient until some patient takes action
        final appointmentWithDoctorId = appointment.copyWith(
            id: generatedId, doctorId: doctorId, patientId: "");
        await _consumer.set('${DatabasePaths.appointments}/$generatedId',
            data: appointmentWithDoctorId.toJson());
      }
    } catch (e) {
      throw DatabaseException(
          e.toString(), 'failed-to-create-an-appointment-not-authorized');
    }
  }

  @override
  Future<void> updateAppointment(
    AppointmentModel appointment,
  ){
    
  }

  @override
  Future<void> completeAppointment(
    String appointmentId,
  );

  @override
  Future<void> cancelAppointment(
    String appointmentId,
  );
}
