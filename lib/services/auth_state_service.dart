import 'package:shared_preferences/shared_preferences.dart';

class AuthStateService {
  late SharedPreferences _prefs;
  final String _isLoggedInKey = 'is_logged_in';
  final String _isOnlineKey = 'is_online';

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<bool> isLoggedIn() async {
    return _prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<void> login() async {
    await _prefs.setBool(_isLoggedInKey, true);
  }

  Future<void> logout() async {
    await _prefs.setBool(_isLoggedInKey, false);
  }
  Future<bool> getOnlineStatus() async {
    return _prefs.getBool(_isOnlineKey) ?? false;
  }

  Future<void> setOnlineStatus(bool isOnline) async {
    await _prefs.setBool(_isOnlineKey, isOnline);
  }
}