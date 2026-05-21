class AuthResponseModel {
  final String id;
  final String email;
  final String fullName;
  final String token;
  final String role;
  final String gender;
  final int expiresIn;

  AuthResponseModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.token,
    required this.role,
    required this.gender,
    required this.expiresIn,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      id: json['id'],
      email: json['email'],
      fullName: json['fullName'],
      token: json['token'],
      role: json['role'],
      gender: json['gender'],
      expiresIn: json['expires_in'],
    );
  }
}