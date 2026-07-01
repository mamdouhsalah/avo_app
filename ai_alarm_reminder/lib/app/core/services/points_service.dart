import 'package:hive_flutter/hive_flutter.dart';

class PointsService {
  static const String _boxName = 'user_points';
  static const String _pointsKey = 'points';

  static Future<void> init() async {
    await Hive.openBox(_boxName);
    if (_box.get(_pointsKey) == null) {
      await _box.put(_pointsKey, 10); // Initial 10 points
    }
  }

  static Box get _box => Hive.box(_boxName);

  static int get points => _box.get(_pointsKey, defaultValue: 0);

  static Future<void> addPoints(int amount) async {
    await _box.put(_pointsKey, points + amount);
  }

  static Future<bool> spendPoints(int amount) async {
    if (points >= amount) {
      await _box.put(_pointsKey, points - amount);
      return true;
    }
    return false;
  }
}
