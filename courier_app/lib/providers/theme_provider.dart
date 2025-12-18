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
    if (savedTheme == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }
    notifyListeners();
  }

  // --- ИЗМЕНЕНО: Теперь метод возвращает Future, чтобы его можно было дождаться ---
  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    // Мы дожидаемся сохранения, прежде чем уведомить слушателей
    await _saveTheme(); 
    notifyListeners();
  }

  // --- ИЗМЕНЕНО: Метод теперь сохраняет текущее состояние _themeMode ---
  Future<void> _saveTheme() async {
    final themeToSave = _themeMode == ThemeMode.dark ? 'dark' : 'light';
    await _prefs.setString(_themeKey, themeToSave);
  }
}
