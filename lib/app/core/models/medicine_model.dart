class MedicineModel {
  final String id;
  final String name;
  final String dosage;
  final String time;
  final bool isTaken;
  final String? imageUrl;

  const MedicineModel({
    required this.id,
    required this.name,
    required this.dosage,
    required this.time,
    required this.isTaken,
    this.imageUrl,
  });

  MedicineModel copyWith({bool? isTaken}) {
    return MedicineModel(
      id: id,
      name: name,
      dosage: dosage,
      time: time,
      isTaken: isTaken ?? this.isTaken,
      imageUrl: imageUrl,
    );
  }

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    return MedicineModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      dosage: json['dosage'] ?? '',
      time: json['time'] ?? '',
      isTaken: json['is_taken'] ?? false,
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'time': time,
      'is_taken': isTaken,
      'image_url': imageUrl,
    };
  }
}
