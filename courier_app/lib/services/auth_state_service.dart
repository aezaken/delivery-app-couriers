import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_data/services/api_service.dart';
import 'location_service.dart';

class AuthStateService {
  late SharedPreferences _prefs;
  final String _isLoggedInKey = 'is_logged_in';
  final String _isOnlineKey = 'is_online';

  final ApiService _apiService;
  late final LocationService _locationService;

  AuthStateService(this._apiService) {
    _locationService = LocationService(_apiService);
  }

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
    await setOnlineStatus(false); // Убеждаемся, что отслеживание остановлено
  }

  Future<bool> getOnlineStatus() async {
    return _prefs.getBool(_isOnlineKey) ?? false;
  }

  Future<void> setOnlineStatus(bool isOnline) async {
    await _prefs.setBool(_isOnlineKey, isOnline);
    try {
      if (isOnline) {
        await _locationService.startLocationUpdates();
      } else {
        _locationService.stopLocationUpdates();
      }
    } catch (e) {
      // Логируем ошибку, но не даем ей сломать приложение.
      // UI не должен зависать, если геолокация не запустилась.
      print("!!! Ошибка запуска/остановки LocationService: $e");
    }
  }
}
