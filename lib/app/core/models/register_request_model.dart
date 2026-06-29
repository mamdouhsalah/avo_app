class RegisterRequestModel {
  final String fullName;
  final String email;
  final String password;
  final String role;
  final String phoneNumber;
  final String gender;
  final String dateOfBirth;
  final num? height;
  final num? weight;
  final String? image;
  final String? location;
  final String? specialty;
  final num? price;

  RegisterRequestModel({
    required this.fullName,
    required this.email,
    required this.password,
    required this.role,
    required this.phoneNumber,
    required this.gender,
    required this.dateOfBirth,
    this.height,
    this.weight,
    this.image,
    this.location,
    this.specialty,
    this.price,
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
        height: null,
        weight: null,
        location: null,
        specialty: null,
        price: null,
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
      height: json['height'] as num?,
      weight: json['weight'] as num?,
      image: json['image']?.toString(),
      location: json['location']?.toString(),
      specialty: json['specialty']?.toString(),
      price: json['price'] as num?,
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
      if (height != null) 'height': height,
      if (weight != null) 'weight': weight,
      if (image != null) 'image': image,
      if (location != null) 'location': location,
      if (specialty != null) 'specialty': specialty,
      if (price != null) 'price': price,
    };
  }
}