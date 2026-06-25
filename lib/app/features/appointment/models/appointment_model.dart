enum AppointmentStatus {
  upcoming,
  completed,
  canceled,
}

// from enum to string
extension AppointmentStatusExtension on AppointmentStatus {
  String get value {
    switch (this) {
      case AppointmentStatus.upcoming:
        return 'upcoming';
      case AppointmentStatus.completed:
        return 'completed';
      case AppointmentStatus.canceled:
        return 'canceled';
    }
  }

  static AppointmentStatus fromString(String value) {
    switch (value) {
      case 'completed':
        return AppointmentStatus.completed;
      case 'canceled':
        return AppointmentStatus.canceled;
      case 'upcoming':
      default:
        return AppointmentStatus.upcoming;
    }
  }
}

class AppointmentModel {
  final String id;

  /// Firebase Auth UID of doctor => we will get the rest of doctor data via this
  final String doctorId;

  /// Firebase Auth UID of patient
  final String patientId;

  final DateTime appointmentDate;

  final String timeStart;
  final String timeEnd;

  final AppointmentStatus status;

  /// Available only after completed appointments
  final double? patientRating;

  final bool isFavorite;

  AppointmentModel({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.appointmentDate,
    required this.timeStart,
    required this.timeEnd,
    required this.status,
    this.patientRating,
    required this.isFavorite
  });

  factory AppointmentModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AppointmentModel(
      id: json['id'] ?? '',
      doctorId: json['doctorId'] ?? '',
      patientId: json['patientId'] ?? '',
      appointmentDate: DateTime.parse(
        json['appointmentDate'],
      ),
      timeStart: json['timeStart'] ?? '',
      timeEnd: json['timeEnd'] ?? '',
      status: AppointmentStatusExtension.fromString(
        json['status'] ?? 'upcoming',
      ),
      patientRating: (json['patientRating'] as num?)?.toDouble(),
      isFavorite: json['isFavorite']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': doctorId,
      'patientId': patientId,
      'appointmentDate': appointmentDate.toIso8601String(),
      'timeStart': timeStart,
      'timeEnd': timeEnd,
      'status': status.value,
      'patientRating': patientRating,
      'isFavorite':isFavorite
    };
  }

  AppointmentModel copyWith({
    String? id,
    String? doctorId,
    String? patientId,
    DateTime? appointmentDate,
    String? timeStart,
    String? timeEnd,
    AppointmentStatus? status,
    double? patientRating,
    String? patientReview,
    bool?isFavourite
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      patientId: patientId ?? this.patientId,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      timeStart: timeStart ?? this.timeStart,
      timeEnd: timeEnd ?? this.timeEnd,
      status: status ?? this.status,
      patientRating: patientRating ?? this.patientRating,
      isFavorite: isFavourite?? this.isFavorite
    );
  }
}
