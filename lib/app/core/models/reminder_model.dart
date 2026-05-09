class ReminderModel {
  final String id;
  final String name;
  final String dosage;
  final String pillCount;
  final String time;
  final String frequency;
  final bool isActive;
  final String status;

  ReminderModel({
    required this.id,
    required this.name,
    required this.dosage,
    required this.pillCount,
    required this.time,
    required this.frequency,
    required this.isActive,
    required this.status,
  });
}