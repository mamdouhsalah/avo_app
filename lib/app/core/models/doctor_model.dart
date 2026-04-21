class DoctorModel {
  final String id;
  final String name;
  final String specialty;
  final double rating;
  final int reviews;
  final String openTime;
  final String closeTime;
  final bool isFavorite;
  final String? imageUrl;

  const DoctorModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.reviews,
    required this.openTime,
    required this.closeTime,
    this.isFavorite = false,
    this.imageUrl,
  });

  DoctorModel copyWith({bool? isFavorite}) {
    return DoctorModel(
      id: id,
      name: name,
      specialty: specialty,
      rating: rating,
      reviews: reviews,
      openTime: openTime,
      closeTime: closeTime,
      isFavorite: isFavorite ?? this.isFavorite,
      imageUrl: imageUrl,
    );
  }
}