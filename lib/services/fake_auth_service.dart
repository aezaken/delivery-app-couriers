import 'auth_service.dart';

class FakeAuthService implements AuthService {
  // Тестовые учетные данные
  final String testPhone = "1234567890";
  final String testPassword = "password";

  @override
  Future<bool> login(String phone, String password) async {
    // Имитация задержки сети (2 секунды)
    await Future.delayed(const Duration(seconds: 2));

    // Проверяем тестовые данные
    if (phone == testPhone && password == testPassword) {
      return true; // Успешный вход
    } else {
      return false; // Неверные учетные данные
    }
  }
}