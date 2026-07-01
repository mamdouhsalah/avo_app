class FavoriteModel {
  final String patientId;
  final Map<String, bool> doctorIds; // doctorId -> true/false, null = false

  const FavoriteModel({
    required this.patientId,
    required this.doctorIds,
  });

  bool isFavorite(String doctorId) => doctorIds[doctorId] ?? false;

  factory FavoriteModel.fromJson(String patientId, Map<dynamic, dynamic>? json) {
    return FavoriteModel(
      patientId: patientId,
      doctorIds: json?.map(
            (key, value) => MapEntry(key.toString(), value == true),
          ) ??
          {},
    );
  }

  Map<String, dynamic> toJson() => doctorIds;
}