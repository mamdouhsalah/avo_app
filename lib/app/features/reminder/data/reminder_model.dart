class ReminderModel {
  final String id;
  final String name;
  final String dosage;
  final String pillCount;
  final String time;
  final String status;
  final String frequency;
  final bool isActive;

  ReminderModel({
    required this.id,
    required this.name,
    required this.dosage,
    required this.pillCount,
    required this.time,
    required this.status,
    required this.frequency,
    required this.isActive,
  });

  ReminderModel copyWith({
    String? id,
    String? name,
    String? dosage,
    String? pillCount,
    String? time,
    String? status,
    String? frequency,
    bool? isActive,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      pillCount: pillCount ?? this.pillCount,
      time: time ?? this.time,
      status: status ?? this.status,
      frequency: frequency ?? this.frequency,
      isActive: isActive ?? this.isActive,
    );
  }
}