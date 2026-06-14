class UserProfileModel {
  final String email;
  final String fullName;
  final String role;
  final String gender;
  final String dateOfBirth;
  final String phoneNumber;
  final int height;
  final int weight;
  final String image;

  UserProfileModel({
    required this.email,
    required this.fullName,
    required this.role,
    required this.gender,
    required this.dateOfBirth,
    required this.phoneNumber,
    required this.height,
    required this.weight,
    required this.image,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      email: json['email'],
      fullName: json['full_name'],
      role: json['role'],
      gender: json['gender'],
      dateOfBirth: json['date_of_birth'],
      phoneNumber: json['phone_number'],
      height: json['height'],
      weight: json['weight'],
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'full_name': fullName,
      'role': role,
      'gender': gender,
      'date_of_birth': dateOfBirth,
      'phone_number': phoneNumber,
      'height': height,
      'weight': weight,
      'image': image,
    };
  }
}