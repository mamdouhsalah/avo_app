import 'package:hive/hive.dart';

class PreferencesService {
  static const _themeKey = 'app_theme';
  static const _languageKey = 'app_language';

  Box get _box => Hive.box('settings');

  String getTheme() => _box.get(_themeKey, defaultValue: 'light');
  Future<void> saveTheme(String theme) => _box.put(_themeKey, theme);
  Future<void> clearTheme() => _box.delete(_themeKey);

  String getLanguage() => _box.get(_languageKey, defaultValue: 'en');
  Future<void> saveLanguage(String language) => _box.put(_languageKey, language);
  Future<void> clearLanguage() => _box.delete(_languageKey);
}
