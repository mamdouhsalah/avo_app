class PatientModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? image;
  final String role;
  final bool isVerified;
  final String? diagnosis; // إضافة حقل التشخيص

  const PatientModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.image,
    required this.role,
    this.isVerified = false,
    this.diagnosis, // تهيئة حقل التشخيص
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      image: json['image'],
      role: json['role'] ?? 'patient',
      isVerified: json['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'image': image,
      'role': role,
      'isVerified': isVerified,
    };
  }
}
