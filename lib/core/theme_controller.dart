import 'package:flutter/material.dart';

import '../data/services/local_storage_service.dart';

class ThemeController extends ChangeNotifier {
  ThemeController._internal();
  static final ThemeController _instance = ThemeController._internal();
  factory ThemeController() => _instance;

  final LocalStorageService _storage = LocalStorageService();

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  Future<void> load() async {
    final raw = await _storage.getThemeModeRaw();
    _themeMode = _rawToMode(raw) ?? ThemeMode.system;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _storage.setThemeModeRaw(_modeToRaw(mode));
    notifyListeners();
  }

  String _modeToRaw(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  ThemeMode? _rawToMode(String? raw) {
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return null;
    }
  }
}
