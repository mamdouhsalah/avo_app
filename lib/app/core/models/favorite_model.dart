class FavoriteModel {
  final String patientId;
  final Map<String, bool> doctorIds; // doctorId -> true/false, null = false
  final Map<String, bool> pharmacyIds; // pharmacyId -> true/false, null = false

  const FavoriteModel({
    required this.patientId,
    required this.doctorIds,
    required this.pharmacyIds,
  });

  bool isFavoriteDoctor(String doctorId) => doctorIds[doctorId] ?? false;
  bool isFavoritePharmacy(String pharmacyId) => pharmacyIds[pharmacyId] ?? false;

  factory FavoriteModel.fromJson(String patientId, Map<dynamic, dynamic>? json) {
    if (json == null) return FavoriteModel(patientId: patientId, doctorIds: {}, pharmacyIds: {});
    
    final dIds = json['doctors'] as Map<dynamic, dynamic>?;
    final pIds = json['pharmacies'] as Map<dynamic, dynamic>?;

    return FavoriteModel(
      patientId: patientId,
      doctorIds: dIds?.map(
            (key, value) => MapEntry(key.toString(), value == true),
          ) ??
          {},
      pharmacyIds: pIds?.map(
            (key, value) => MapEntry(key.toString(), value == true),
          ) ??
          {},
    );
  }

  Map<String, dynamic> toJson() => {
    'doctors': doctorIds,
    'pharmacies': pharmacyIds,
  };
}