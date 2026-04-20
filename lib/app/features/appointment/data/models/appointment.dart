enum AppointmentStatus {
  upcoming,
  completed,
  canceled,
}

class Appointment {
  final String id;
  final String doctorName;
  final String specialty;
  final String clinic;
  final double rating;
  final String date;
  final String timeStart;
  final String timeEnd;
  final AppointmentStatus status;

  Appointment({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.clinic,
    required this.rating,
    required this.date,
    required this.timeStart,
    required this.timeEnd,
    required this.status,
  });
}
