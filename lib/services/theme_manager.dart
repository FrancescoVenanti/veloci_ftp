// lib/services/theme_manager.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { light, dark, system }

class ThemeManager extends ChangeNotifier {
  static ThemeManager? _instance;
  static ThemeManager get instance {
    _instance ??= ThemeManager._();
    return _instance!;
  }

  ThemeManager._();

  static const String _themeKey = 'app_theme_mode';
  AppThemeMode _currentTheme = AppThemeMode.system;
  SharedPreferences? _prefs;

  AppThemeMode get currentTheme => _currentTheme;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    final savedTheme = _prefs?.getString(_themeKey);

    if (savedTheme != null) {
      _currentTheme = AppThemeMode.values.firstWhere(
        (theme) => theme.name == savedTheme,
        orElse: () => AppThemeMode.system,
      );
    }

    notifyListeners();
  }

  Future<void> setTheme(AppThemeMode theme) async {
    _currentTheme = theme;
    await _prefs?.setString(_themeKey, theme.name);
    notifyListeners();
  }

  ThemeMode getThemeMode() {
    switch (_currentTheme) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  bool isDarkMode(BuildContext context) {
    switch (_currentTheme) {
      case AppThemeMode.light:
        return false;
      case AppThemeMode.dark:
        return true;
      case AppThemeMode.system:
        return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
  }
}
