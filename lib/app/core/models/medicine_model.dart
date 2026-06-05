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

  factory MedicineModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const MedicineModel(
        id: '',
        name: '',
        dosage: '',
        time: '',
        isTaken: false,
      );
    }
    return MedicineModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      dosage: json['dosage']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      isTaken: json['is_taken'] as bool? ?? false,
      imageUrl: json['image_url']?.toString(),
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
