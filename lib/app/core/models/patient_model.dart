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

  factory PatientModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PatientModel(
        id: '',
        name: '',
        email: '',
        phone: '',
        role: 'patient',
        isVerified: false,
      );
    }
    return PatientModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      image: json['image']?.toString(),
      role: json['role']?.toString() ?? 'patient',
      isVerified: json['isVerified'] as bool? ?? false,
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
