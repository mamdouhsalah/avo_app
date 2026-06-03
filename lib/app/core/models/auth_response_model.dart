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

  factory AuthResponseModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return AuthResponseModel(
        id: '',
        email: '',
        fullName: '',
        token: '',
        role: '',
        gender: '',
        expiresIn: 0,
      );
    }
    return AuthResponseModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      expiresIn: (json['expires_in'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'token': token,
      'role': role,
      'gender': gender,
      'expires_in': expiresIn,
    };
  }
}