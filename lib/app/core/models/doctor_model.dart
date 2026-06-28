import 'package:avo_app/app/core/models/schedule_model.dart';
import 'package:avo_app/app/core/models/user_profile_model.dart';

class DoctorModel extends UserProfileModel {
  final String specialty;
  final String? location;
  final double rating;
  final int numberOfReviews;
  final double price;
  final String bio;
  final int patientsTreated;
  final List<ScheduleModel>? schedules;
  final bool isFavorite;

  String get imageUrl => image;
  String get name => fullName;

  const DoctorModel({
    required super.id,
    required super.email,
    required super.fullName,
    required super.role,
    required super.gender,
    required super.dateOfBirth,
    required super.phoneNumber,
    super.height,
    super.weight,
    required super.image,
    required super.isVerified,
    required this.specialty,
    this.location,
    required this.rating,
    required this.numberOfReviews,
    this.price = 0.0,
    this.bio = '',
    this.patientsTreated = 0,
    this.schedules,
    this.isFavorite = false,
  });

  factory DoctorModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const DoctorModel(
        id: '',
        email: '',
        fullName: '',
        role: 'doctor',
        gender: '',
        dateOfBirth: '',
        phoneNumber: '',
        height: null,
        weight: null,
        image: '',
        isVerified: false,
        specialty: '',
        rating: 0.0,
        numberOfReviews: 0,
        price: 0.0,
        bio: '',
        patientsTreated: 0,
      );
    }
    return DoctorModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? json['full_name']?.toString() ?? '',
      role: json['role']?.toString() ?? 'doctor',
      gender: json['gender']?.toString() ?? '',
      dateOfBirth: json['date_of_birth']?.toString() ?? json['dateOfBirth']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? json['phoneNumber']?.toString() ?? '',
      height: json['height'] != null ? (json['height'] as num).toInt() : null,
      weight: json['weight'] != null ? (json['weight'] as num).toInt() : null,
      image: json['imageUrl']?.toString() ?? json['image']?.toString() ?? '',
      isVerified: json['is_verified'] as bool? ?? json['isVerified'] as bool? ?? false,
      specialty: json['specialty']?.toString() ?? '',
      location: json['location']?.toString(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      numberOfReviews: (json['numberOfReviews'] as num?)?.toInt() ?? json['reviews'] as int? ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      bio: json['bio']?.toString() ?? '',
      patientsTreated: (json['patientsTreated'] as num?)?.toInt() ?? 0,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'full_name': fullName,
      'role': role,
      'gender': gender,
      'date_of_birth': dateOfBirth,
      'phone_number': phoneNumber,
      if (height != null) 'height': height,
      if (weight != null) 'weight': weight,
      'image': image,
      'is_verified': isVerified,
      'specialty': specialty,
      'location': location,
      'rating': rating,
      'numberOfReviews': numberOfReviews,
      'price': price,
      'bio': bio,
      'patientsTreated': patientsTreated,
      'isFavorite': isFavorite,
    };
  }
}
