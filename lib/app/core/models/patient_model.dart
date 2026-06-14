class PatientModel {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? image;
  final String role;
  final bool isVerified;
  final String dateOfBirth;
  final String gender;
  final String? diagnosis; // إضافة حقل التشخيص

  const PatientModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.image,
    required this.role,
    this.isVerified = false,
    this.dateOfBirth = '',
    this.gender = '',
    this.diagnosis, // تهيئة حقل التشخيص
  });

  factory PatientModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PatientModel(
        id: '',
        fullName: '',
        email: '',
        phoneNumber: '',
        role: 'patient',
        isVerified: false,
        dateOfBirth: '',
        gender: '',
      );
    }
    return PatientModel(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? '',
      image: json['image']?.toString(),
      role: json['role']?.toString() ?? 'patient',
      isVerified: json['is_verified'] as bool? ?? false,
      dateOfBirth: json['date_of_birth']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'image': image,
      'role': role,
      'is_verified': isVerified,
      'date_of_birth': dateOfBirth,
      'gender': gender,
    };
  }
}
