class MedicineModel {
  final String id;
  final String name;
  final String dosage;
  final String time;
  final bool isTaken;
  final String? imageUrl;
  final String? doctorId;
  final String? patientId;
  final DateTime? date;
  final String? instructions;

  const MedicineModel({
    required this.id,
    required this.name,
    required this.dosage,
    required this.time,
    required this.isTaken,
    this.imageUrl,
    this.doctorId,
    this.patientId,
    this.date,
    this.instructions,
  });

  MedicineModel copyWith({bool? isTaken}) {
    return MedicineModel(
      id: id,
      name: name,
      dosage: dosage,
      time: time,
      isTaken: isTaken ?? this.isTaken,
      imageUrl: imageUrl ?? this.imageUrl,
      doctorId: doctorId ?? this.doctorId,
      patientId: patientId ?? this.patientId,
      date: date ?? this.date,
      instructions: instructions ?? this.instructions,
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
      doctorId: json['doctor_id']?.toString(),
      patientId: json['patient_id']?.toString(),
      date: json['date'] != null ? DateTime.tryParse(json['date'].toString()) : null,
      instructions: json['instructions']?.toString(),
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
      if (doctorId != null) 'doctor_id': doctorId,
      if (patientId != null) 'patient_id': patientId,
      if (date != null) 'date': date?.toIso8601String(),
      if (instructions != null) 'instructions': instructions,
    };
  }
}
