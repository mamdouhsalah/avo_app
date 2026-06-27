import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:avo_app/app/core/services/local/preferences_service.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final PreferencesService _preferencesService;

  ThemeCubit(this._preferencesService) : super(ThemeMode.system) {
    _loadSavedTheme();
  }

  void _loadSavedTheme() {
    final saved = _preferencesService.getTheme();
    emit(saved == 'dark' ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleTheme() {
    if (state == ThemeMode.light || state == ThemeMode.system) {
      setTheme(ThemeMode.dark);
    } else {
      setTheme(ThemeMode.light);
    }
  }

  void setTheme(ThemeMode themeMode) {
    if (themeMode == ThemeMode.system) {
      _preferencesService.clearTheme();
    } else {
      _preferencesService.saveTheme(themeMode == ThemeMode.dark ? 'dark' : 'light');
    }
    emit(themeMode);
  }
}