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
  });

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
    };
  }
}