enum AppointmentStatus {
  available, // doctor created slot, nobody booked yet
  pending, // patient requested booking
  confirmed, // doctor accepted
  completed, // finished
  canceled, // canceled by doctor or patient
  upcoming // patient booked it but still in future
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
      case AppointmentStatus.available:
        return 'avialable';
      case AppointmentStatus.pending:
        return 'pending';
      case AppointmentStatus.confirmed:
        return 'confirmed';
    }
  }

  static AppointmentStatus fromString(String value) {
    switch (value) {
      case 'completed':
        return AppointmentStatus.completed;
      case 'canceled':
        return AppointmentStatus.canceled;
      case 'upcoming':
        return AppointmentStatus.upcoming;
      case 'pending':
        return AppointmentStatus.pending;
      case 'confirmed':
        return AppointmentStatus.confirmed;
      default:
        return AppointmentStatus.available;
    }
  }
}

class AppointmentModel {
  final String id;

  /// Firebase Auth UID of doctor => we will get the rest of doctor data via this
  final String doctorId;

  /// Firebase Auth UID of patient
  final String? patientId;

  final DateTime appointmentDate;

  final String timeStart;
  final String timeEnd;

// will be set from doctor wise
  final String title; // like : stomach checkup
  final String room; // like : room 4

  final AppointmentStatus status;

  /// Available only after completed appointments
  final double? patientRating;

  final bool isFavorite;

  final String? canceledBy; // for knowing the person who canceled the appointment patinet / doctor

  AppointmentModel(
      {required this.id,
      required this.doctorId,
      this.patientId,
      required this.appointmentDate,
      required this.timeStart,
      required this.timeEnd,
      required this.status,
      this.patientRating,
      required this.isFavorite,
      required this.room,
      required this.title,
      this.canceledBy
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
        isFavorite: json['isFavorite'] ?? false,
        room: json['room']??'',
        title: json['title']??'',
        canceledBy: json['canceledBy']??''
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
      'isFavorite': isFavorite,
      'room' :room,
      'title':title,
      'canceledBy':canceledBy
    };
  }

  AppointmentModel copyWith(
      {String? id,
      String? doctorId,
      String? patientId,
      DateTime? appointmentDate,
      String? timeStart,
      String? timeEnd,
      AppointmentStatus? status,
      double? patientRating,
      String? patientReview,
      bool? isFavorite,
      String?room,
      String?canceledBy, // i feel this is missing up but leave it like it is
      String? title
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
        isFavorite: isFavorite ?? this.isFavorite,
        room: room ?? this.room,
        title: title??this.title,
        canceledBy: canceledBy??this.canceledBy
        );
  }
}
