import 'package:avo_app/app/core/models/doctor_model.dart';
import 'package:avo_app/app/core/models/timerange_model.dart';

class AppointmentModel {
  final String id;
  final DoctorModel doctor;
  final double rating;
  final bool isFavorite;
  final TimeRange timeRange;
  final DateTime date;

  const AppointmentModel({
    required this.id,
    required this.doctor,
    required this.rating,
    required this.isFavorite,
    required this.timeRange,
    required this.date,
  });
}
