class RegisterRequestModel {
  final String fullName;
  final String email;
  final String password;
  final String role;
  final String phoneNumber;
  final String gender;
  final String dateOfBirth;
  final num height;
  final num weight;
  final String? image;

  RegisterRequestModel({
    required this.fullName,
    required this.email,
    required this.password,
    required this.role,
    required this.phoneNumber,
    required this.gender,
    required this.dateOfBirth,
    required this.height,
    required this.weight,
    this.image,
  });

  factory RegisterRequestModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return RegisterRequestModel(
        fullName: '',
        email: '',
        password: '',
        role: '',
        phoneNumber: '',
        gender: '',
        dateOfBirth: '',
        height: 0,
        weight: 0,
      );
    }
    return RegisterRequestModel(
      fullName: json['full_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      dateOfBirth: json['date_of_birth']?.toString() ?? '',
      height: json['height'] as num? ?? 0,
      weight: json['weight'] as num? ?? 0,
      image: json['image']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'email': email,
      'password': password,
      'role': role,
      'phone_number': phoneNumber,
      'gender': gender,
      'date_of_birth': dateOfBirth,
      'height': height,
      'weight': weight,
      if (image != null) 'image': image,
    };
  }
}