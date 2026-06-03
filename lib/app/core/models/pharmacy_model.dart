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

  factory PharmacyModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PharmacyModel(
        id: '',
        name: '',
        type: '',
        rating: 0.0,
        reviews: 0,
        openTime: '',
        closeTime: '',
        isFavorite: false,
      );
    }
    return PharmacyModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviews: (json['reviews'] as num?)?.toInt() ?? 0,
      openTime: json['open_time']?.toString() ?? '',
      closeTime: json['close_time']?.toString() ?? '',
      imageUrl: json['image_url']?.toString(),
      isFavorite: json['is_favorite'] as bool? ?? false,
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
