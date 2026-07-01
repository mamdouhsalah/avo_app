import 'package:hive/hive.dart';

part 'models.g.dart';

@HiveType(typeId: 0)
class Medication extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  double dose;

  @HiveField(2)
  String unit;

  @HiveField(3)
  List<String> times;

  @HiveField(4)
  List<String> days;

  @HiveField(5)
  String instructions;

  Medication({
    required this.name,
    required this.dose,
    required this.unit,
    required this.times,
    required this.days,
    required this.instructions,
  });
}

@HiveType(typeId: 1)
class Analysis extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  String labName;

  @HiveField(3)
  String notes;

  Analysis({
    required this.name,
    required this.date,
    required this.labName,
    required this.notes,
  });
}

@HiveType(typeId: 2)
class Appointment extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  DateTime dateTime;

  @HiveField(2)
  String location;

  @HiveField(3)
  String notes;

  Appointment({
    required this.title,
    required this.dateTime,
    required this.location,
    required this.notes,
  });
}

@HiveType(typeId: 3)
class Weight extends HiveObject {
  @HiveField(0)
  double weight;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  String notes;

  @HiveField(3)
  bool remind;

  Weight({
    required this.weight,
    required this.date,
    required this.notes,
    required this.remind,
  });
}

@HiveType(typeId: 8)
class HealthMetric extends HiveObject {
  @HiveField(0)
  String type; // 'sugar', 'pressure_systolic', 'pressure_diastolic', 'weight', 'sleep'

  @HiveField(1)
  double value;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  String? unit;

  @HiveField(4)
  String? notes;

  @HiveField(5)
  bool remind;

  String get name {
    return {
          'sugar': 'سكر الدم',
          'pressure': 'ضغط الدم',
          'pressure_systolic': 'ضغط الدم (انقباضي)',
          'pressure_diastolic': 'ضغط الدم (انبساطي)',
          'weight': 'الوزن',
          'sleep': 'ساعات النوم',
        }[type] ??
        type;
  }

  HealthMetric({
    required this.type,
    required this.value,
    required this.date,
    this.unit,
    this.notes,
    this.remind = false,
  });
}

@HiveType(typeId: 5)
class MedicationLog extends HiveObject {
  @HiveField(0)
  int medicationKey; // Reference to Medication's key

  @HiveField(1)
  DateTime timestamp;

  @HiveField(2)
  String action; // 'took', 'skipped', 'snoozed'

  @HiveField(3)
  int notificationId;

  MedicationLog({
    required this.medicationKey,
    required this.timestamp,
    required this.action,
    required this.notificationId,
  });
}
