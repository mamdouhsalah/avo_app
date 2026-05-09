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
    required this.isFavorite,
  });

  PharmacyModel copyWith({bool? isFavorite}) {
    return PharmacyModel(
      id: id,
      name: name,
      type: type,
      rating: rating,
      reviews: reviews,
      openTime: openTime,
      closeTime: closeTime,
      imageUrl: imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory PharmacyModel.fromJson(Map<String, dynamic> json) {
    return PharmacyModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviews: json['reviews'] ?? 0,
      openTime: json['open_time'] ?? '',
      closeTime: json['close_time'] ?? '',
      imageUrl: json['image_url'],
      isFavorite: json['is_favorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'rating': rating,
      'reviews': reviews,
      'open_time': openTime,
      'close_time': closeTime,
      'image_url': imageUrl,
      'is_favorite': isFavorite,
    };
  }
}
