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
}
