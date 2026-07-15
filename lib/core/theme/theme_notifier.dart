import 'package:flutter/material.dart';
import '../storage/local_storage.dart';

class ThemeNotifier extends ChangeNotifier {
  final LocalStorage _storage;
  late ThemePreference _currentTheme;

  ThemeNotifier(this._storage) {
    _currentTheme = _storage.getTheme();
  }

  ThemePreference get currentTheme => _currentTheme;

  ThemeMode get themeMode {
    switch (_currentTheme) {
      case ThemePreference.light:
        return ThemeMode.light;
      case ThemePreference.dark:
        return ThemeMode.dark;
      case ThemePreference.sepia:
        return ThemeMode.light;
      case ThemePreference.amoled:
        return ThemeMode.dark;
    }
  }

  void setTheme(ThemePreference theme) {
    _currentTheme = theme;
    _storage.setTheme(theme);
    notifyListeners();
  }
}
