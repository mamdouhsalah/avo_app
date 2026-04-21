class PharmacyModel {
  final String id;
  final String name;
  final String type;
  final double rating;
  final int reviews;
  final String openTime;
  final String closeTime;
  final String? imageUrl;
  final bool isFavorite;

  const PharmacyModel({
    required this.id,
    required this.name,
    required this.type,
    required this.rating,
    required this.reviews,
    required this.openTime,
    required this.closeTime,
    this.imageUrl,
    required this.isFavorite ,
  });
}
