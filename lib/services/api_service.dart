import 'package:dio/dio.dart';

class ApiService {
  // Базовый URL вашего будущего сервера
  static const String baseUrl = 'https://api.yourserver.com'; // <-- ЗАМЕНИТЕ НА ВАШ АДРЕС СЕРВЕРА

  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10), // Таймаут соединения
    receiveTimeout: const Duration(seconds: 10), // Таймаут получения ответа
  ));

  // В будущем здесь будут методы для:
  // 1. Логина (POST /login)
  // 2. Получения активного заказа (GET /courier/active-order)
  // 3. Отправки геолокации (POST /courier/location)
  // 4. Обновления статуса заказа (POST /order/{id}/status)

  // Пример метода логина (пока заглушка)
  Future<String?> login(String phone, String password) async {
    try {
      // Здесь будет реальный запрос к вашему API
      /*
      final response = await _dio.post('/login', data: {
        'phone': phone,
        'password': password,
      });

      if (response.statusCode == 200) {
        // Возвращаем токен
        return response.data['token'];
      }
      */

      // Пока возвращаем тестовый токен
      if (phone == '1234567890' && password == 'password') {
        return 'test_jwt_token_12345';
      }
      return null;

    } on DioException catch (e) {
      // Обработка ошибок сети/сервера
      print('API Error during login: $e');
      return null;
    }
  }
}