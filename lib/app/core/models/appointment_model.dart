class AppointmentModel {
  final String id;
  final String doctorName;
  final String specialty;
  final double rating;
  final int reviews;
  final String date;
  final String time;
  final String? imageUrl;

  const AppointmentModel({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.rating,
    required this.reviews,
    required this.date,
    required this.time,
    this.imageUrl,
  });
}