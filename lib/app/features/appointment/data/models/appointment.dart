enum AppointmentStatus {
  upcoming,
  completed,
  canceled,
}

class Appointment {
  final int id;
  final String doctorName;
  final String doctorPictureUrl;
  final String specialty;
  final String clinic;
  final double rating;
  final DateTime date;
  final String timeStart;
  final String timeEnd;
  final AppointmentStatus status;
  final bool isFavorite;

  Appointment({
    required this.id,
    required this.doctorName,
    required this.doctorPictureUrl,
    required this.specialty,
    required this.clinic,
    required this.rating,
    required this.date,
    required this.timeStart,
    required this.timeEnd,
    required this.status,
    required this.isFavorite,
  });
}
