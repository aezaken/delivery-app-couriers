import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  late SharedPreferences _prefs;
  final String _themeKey = 'app_theme';

  ThemeMode get themeMode => _themeMode;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _loadTheme();
  }

  void _loadTheme() {
    final savedTheme = _prefs.getString(_themeKey) ?? 'light';
    _themeMode = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _saveTheme(_themeMode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }

  Future<void> _saveTheme(String theme) async {
    await _prefs.setString(_themeKey, theme);
  }
}