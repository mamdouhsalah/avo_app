import 'package:ai_alarm_reminder/app/core/services/service_models/models.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(MedicationAdapter());
    Hive.registerAdapter(AnalysisAdapter());
    Hive.registerAdapter(AppointmentAdapter());
    Hive.registerAdapter(WeightAdapter());
    Hive.registerAdapter(HealthMetricAdapter());
    Hive.registerAdapter(MedicationLogAdapter());
await Hive.openBox('settings');
    await Hive.openBox<Medication>('medications');
    await Hive.openBox<Analysis>('analyses');
    await Hive.openBox<Appointment>('appointments');
    await Hive.openBox<Weight>('weights');
    await Hive.openBox<HealthMetric>('health_metrics');
    await Hive.openBox<MedicationLog>('medication_logs');
  }

  static Box<Medication> getMedicationBox() =>
      Hive.box<Medication>('medications');
  static Box<Analysis> getAnalysisBox() => Hive.box<Analysis>('analyses');
  static Box<Appointment> getAppointmentBox() =>
      Hive.box<Appointment>('appointments');
  static Box<Weight> getWeightBox() => Hive.box<Weight>('weights');
  static Box<HealthMetric> getHealthMetricBox() =>
      Hive.box<HealthMetric>('health_metrics');
  static Box<MedicationLog> getMedicationLogBox() =>
      Hive.box<MedicationLog>('medication_logs');
}
