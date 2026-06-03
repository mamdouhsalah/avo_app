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

  factory DoctorModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const DoctorModel(
        id: '',
        name: '',
        specialty: '',
        rating: 0.0,
        reviews: 0,
        openTime: '',
        closeTime: '',
      );
    }
    return DoctorModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      specialty: json['specialty']?.toString() ?? '',
      hospital: json['hospital']?.toString(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviews: (json['reviews'] as num?)?.toInt() ?? 0,
      hourlyRate: (json['hourlyRate'] as num?)?.toDouble() ?? 0.0,
      experience: (json['experience'] as num?)?.toInt() ?? 0,
      patientsTreated: (json['patientsTreated'] as num?)?.toInt() ?? 0,
      openTime: json['openTime']?.toString() ?? '',
      closeTime: json['closeTime']?.toString() ?? '',
      isFavorite: json['isFavorite'] as bool? ?? false,
      imageUrl: json['imageUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'hospital': hospital,
      'rating': rating,
      'reviews': reviews,
      'hourlyRate': hourlyRate,
      'experience': experience,
      'patientsTreated': patientsTreated,
      'openTime': openTime,
      'closeTime': closeTime,
      'isFavorite': isFavorite,
      'imageUrl': imageUrl,
    };
  }
}
