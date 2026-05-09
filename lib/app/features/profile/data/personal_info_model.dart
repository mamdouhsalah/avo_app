class PersonalInfoModel {
  final String gender;
  final String height;
  final String weight;
  final String dateOfBirth;
  final String bloodType;
  final String chronicDiseases;

  PersonalInfoModel({
    required this.gender,
    required this.height,
    required this.weight,
    required this.dateOfBirth,
    required this.bloodType,
    required this.chronicDiseases,
  });

  
  PersonalInfoModel copyWith({
    String? gender,
    String? height,
    String? weight,
    String? dateOfBirth,
    String? bloodType,
    String? chronicDiseases,
  }) {
    return PersonalInfoModel(
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bloodType: bloodType ?? this.bloodType,
      chronicDiseases: chronicDiseases ?? this.chronicDiseases,
    );
  }

  factory PersonalInfoModel.fromJson(Map<String, dynamic> json) {
    return PersonalInfoModel(
      gender: json['gender'] ?? 'Male',
      height: json['height'] ?? '',
      weight: json['weight'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? '',
      bloodType: json['bloodType'] ?? '',
      chronicDiseases: json['chronicDiseases'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gender': gender,
      'height': height,
      'weight': weight,
      'dateOfBirth': dateOfBirth,
      'bloodType': bloodType,
      'chronicDiseases': chronicDiseases,
    };
  }
}