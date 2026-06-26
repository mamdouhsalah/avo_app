import 'package:avo_app/app/core/errors/database_exception.dart';
import 'package:avo_app/app/core/models/doctor_model.dart';
import 'package:avo_app/app/core/services/remote/firebase_consumer.dart';
import 'package:avo_app/app/features/doctor/data/doctor_repo.dart';

class DoctorRepositoryImp implements DoctorRepository{
  final FirebaseConsumer _consumer;

  DoctorRepositoryImp({
    required FirebaseConsumer consumer,
  }) : _consumer = consumer;

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
