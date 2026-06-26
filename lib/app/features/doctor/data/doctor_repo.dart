import 'package:avo_app/app/core/models/doctor_model.dart';

abstract class DoctorRepository {

  Future<DoctorModel> getDoctorById(
      String doctorId);

}