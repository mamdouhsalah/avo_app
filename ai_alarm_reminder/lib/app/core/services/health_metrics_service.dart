import 'package:hive_flutter/hive_flutter.dart';
import 'service_models/models.dart';

class HealthMetricsService {
  static const String _boxName = 'health_metrics';

  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(8)) {
      Hive.registerAdapter(HealthMetricAdapter());
    }
    await Hive.openBox<HealthMetric>(_boxName);
  }

  static Box<HealthMetric> get _box => Hive.box<HealthMetric>(_boxName);

  static Future<void> addMetric(HealthMetric metric) async {
    await _box.add(metric);
  }

  static List<HealthMetric> getMetricsByType(String type) {
    return _box.values.where((m) => m.type == type).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  static List<HealthMetric> getAllMetrics() {
    return _box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  static Future<void> deleteMetric(int index) async {
    await _box.deleteAt(index);
  }
}
