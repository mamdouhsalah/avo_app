class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? image;
  final bool isVerified;
  final String? role; // patient / doctor

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.image,
    this.isVerified = false,
  });

  // ── CopyWith ─────────────────────────────
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? image,
    bool? isVerified,
  }) {
    return UserModel(
      role: role ?? this.role,
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      image: image ?? this.image,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  // ── From JSON ────────────────────────────
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      phone: json['phone'],
      image: json['image'],
      isVerified: json['isVerified'] ?? false,
    );
  }

  // ── To JSON ──────────────────────────────
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'image': image,
      'isVerified': isVerified,
      'role': role,
    };
  }

  List<Object?> get props => [id, name, email, phone, image, isVerified, role];
}
