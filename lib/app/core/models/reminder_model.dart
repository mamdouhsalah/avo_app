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

  factory ReminderModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ReminderModel(
        id: '',
        name: '',
        dosage: '',
        pillCount: '',
        time: '',
        frequency: '',
        isActive: false,
        status: '',
      );
    }
    return ReminderModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      dosage: json['dosage']?.toString() ?? '',
      pillCount: json['pillCount']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      frequency: json['frequency']?.toString() ?? '',
      isActive: json['isActive'] as bool? ?? false,
      status: json['status']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'pillCount': pillCount,
      'time': time,
      'frequency': frequency,
      'isActive': isActive,
      'status': status,
    };
  }
}