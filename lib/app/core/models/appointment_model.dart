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

  factory AppointmentModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return AppointmentModel(
        id: '',
        doctor: DoctorModel.fromJson(null),
        rating: 0.0,
        isFavorite: false,
        timeRange: TimeRange.fromJson(null),
        date: DateTime.now(),
      );
    }
    return AppointmentModel(
      id: json['id']?.toString() ?? '',
      doctor: DoctorModel.fromJson(json['doctor'] as Map<String, dynamic>?),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      isFavorite: json['isFavorite'] as bool? ?? false,
      timeRange: TimeRange.fromJson(json['timeRange'] as Map<String, dynamic>?),
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor': doctor.toJson(),
      'rating': rating,
      'isFavorite': isFavorite,
      'timeRange': timeRange.toJson(),
      'date': date.toIso8601String(),
    };
  }
}
