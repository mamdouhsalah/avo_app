class UserProfileModel {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final String gender;
  final String dateOfBirth;
  final String phoneNumber;
  final int height;
  final int weight;
  final String image;
  final bool isVerified;

  UserProfileModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.gender,
    required this.dateOfBirth,
    required this.phoneNumber,
    required this.height,
    required this.weight,
    required this.image,
    required this.isVerified,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return UserProfileModel(
      id: id ?? json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? json['fullName'] ?? '',
      role: json['role'] ?? '',
      gender: json['gender'] ?? '',
      dateOfBirth: json['date_of_birth'] ?? json['dateOfBirth'] ?? '',
      phoneNumber: json['phone_number'] ?? json['phoneNumber'] ?? '',
      height: (json['height'] as num?)?.toInt() ?? 0,
      weight: (json['weight'] as num?)?.toInt() ?? 0,
      image: json['image'] ?? '',
      isVerified: json['is_verified'] ?? json['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
      'gender': gender,
      'date_of_birth': dateOfBirth,
      'phone_number': phoneNumber,
      'height': height,
      'weight': weight,
      'image': image,
      'is_verified': isVerified,
    };
  }
}