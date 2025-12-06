import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  double ballRadius = 30.0;
  ThemeMode themeMode = ThemeMode.system;
  bool _isLoaded = false;

  static const String _radiusKey = 'ball_radius';
  static const String _themeKey = 'theme_mode';

  double get ballMass => (ballRadius / 30.0) * (ballRadius / 30.0);

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    ballRadius = prefs.getDouble(_radiusKey) ?? 30.0;
    final themeIndex = prefs.getInt(_themeKey) ?? ThemeMode.system.index;
    themeMode = ThemeMode.values[themeIndex];
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setBallRadius(double radius) async {
    ballRadius = radius;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_radiusKey, radius);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
    notifyListeners();
  }

  bool get isLoaded => _isLoaded;
}
