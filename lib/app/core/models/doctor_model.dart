class DoctorModel {
  final String id;
  final String name;
  final String specialty;
  final String? hospital;
  final double rating;
  final int reviews;
  final double hourlyRate;
  final int experience;
  final int patientsTreated;
  final String openTime;
  final String closeTime;
  final bool isFavorite;
  final String? imageUrl;

  const DoctorModel({
    required this.id,
    required this.name,
    required this.specialty,
    this.hospital,
    required this.rating,
    required this.reviews,
    this.hourlyRate = 0.0,
    this.experience = 0,
    this.patientsTreated = 0,
    required this.openTime,
    required this.closeTime,
    this.isFavorite = false,
    this.imageUrl,
  });
}
