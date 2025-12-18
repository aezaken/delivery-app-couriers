import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_data/models/login_response.dart';
import 'package:shared_data/models/order.dart';
import 'package:shared_data/models/order_status.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/courier.dart';

class ApiService {
  // Auth paths
  static const String _loginPath = '/auth/login';
  static const String _statusPath = '/auth/status';
  static const String _fcmTokenPath = '/auth/fcm-token';

  // Order paths
  static const String _ordersPath = '/orders';
  static const String _activeOrderPath = '/orders/active';

  // Courier paths
  static const String _onlineCouriersPath = '/couriers/online';
  static const String _locationPath = '/couriers/location';

  // Test paths
  static const String _testDbPath = '/api/test-db-time';

  final String _baseUrl = dotenv.env['API_URL'] ?? 'https://api.yourserver.com';
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (options.path != _loginPath) {
            final prefs = await SharedPreferences.getInstance();
            final token = prefs.getString('auth_token');
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          print('ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}');
          return handler.next(e);
        }
    ));
  }

  Future<LoginResponse?> login(String phone, String password) async {
    try {
      final response = await _dio.post(_loginPath, data: {
        'phone': phone,
        'password': password,
      });

      final loginResponse = LoginResponse.fromJson(response.data);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', loginResponse.token);
      return loginResponse;
    } on DioException catch (e) {
      print('API Error during login: $e');
      throw Exception('Failed to login: ${e.response?.data['message'] ?? e.message}');
    }
  }

  Future<void> updateFcmToken(String fcmToken) async {
    try {
      await _dio.patch(_fcmTokenPath, data: {'fcmToken': fcmToken});
    } on DioException catch (e) {
      // Ошибку не пробрасываем, т.к. это не критичная операция для UI
      print('!!! API Error updating FCM token: $e');
    }
  }

  Future<void> updateOnlineStatus(bool isOnline) async {
    try {
      await _dio.patch(_statusPath, data: {'isOnline': isOnline});
    } on DioException catch (e) {
      print('API Error updating status: $e');
      throw Exception('Failed to update status');
    }
  }

  Future<Order?> getActiveOrder() async {
    try {
      final response = await _dio.get(_activeOrderPath);
      print('Raw response from /orders/active: ${response.data}');

      if (response.data != null && response.data != '') {
        return Order.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      print('API Error getting active order: $e');
      throw Exception('Failed to get active order');
    } catch (e) {
      print('Error parsing active order: $e');
      return null;
    }
  }

  // --- НОВЫЙ МЕТОД ---
  Future<Order?> getOrderById(String orderId) async {
    try {
      final response = await _dio.get('$_ordersPath/$orderId');
      if (response.data != null && response.data != '') {
        return Order.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      print('API Error getting order by ID: $e');
      // Не пробрасываем ошибку, чтобы не сломать приложение, если заказ уже неактуален
      return null;
    }
  }
  // --------------------

  Future<void> updateOrderStatus(int orderId, OrderStatus newStatus) async {
    try {
      String statusString = newStatus.toString().split('.').last;

      await _dio.patch('$_ordersPath/$orderId/status', data: {'status': statusString});

    } on DioException catch (e) {
      print('API Error updating order status: $e');
      throw Exception('Failed to update order status');
    }
  }

  Future<Order> createOrder({required String customerName, required String addressA, required String addressB, int? courierId, double? latA, double? lonA}) async {
    try {
      Map<String, dynamic> payload = {
        'customerName': customerName,
        'addressA': addressA,
        'addressB': addressB,
      };
      
      if (courierId != null) {
        payload['courierId'] = courierId;
      }
      
      if (latA != null && lonA != null) {
        payload['latA'] = latA;
        payload['lonA'] = lonA;
      }
      
      final response = await _dio.post(_ordersPath, data: payload);
      return Order.fromJson(response.data);
    } on DioException catch (e) {
      print('API Error creating order: $e');
      throw Exception('Failed to create order: ${e.response?.data?['message'] ?? e.message}');
    }
  }

  Future<List<Order>> getAllOrders() async {
    try {
      final response = await _dio.get(_ordersPath);
      final List<dynamic> data = response.data;
      return data.map((json) => Order.fromJson(json)).toList();
    } on DioException catch (e) {
      print('API Error getting all orders: $e');
      throw Exception('Failed to get all orders: ${e.response?.data?['message'] ?? e.message}');
    }
  }

  Future<List<Courier>> getOnlineCouriers() async {
    try {
      final response = await _dio.get(_onlineCouriersPath);
      final List<dynamic> data = response.data;
      return data.map((json) => Courier.fromJson(json)).toList();
    } on DioException catch (e) {
      print('API Error getting online couriers: $e');
      throw Exception('Failed to get online couriers: ${e.response?.data?['message'] ?? e.message}');
    }
  }

  Future<void> assignCourier(int orderId, int courierId) async {
    try {
      await _dio.patch('$_ordersPath/$orderId/assign', data: {'courierId': courierId});
    } on DioException catch (e) {
      print('API Error assigning courier: $e');
      throw Exception('Failed to assign courier: ${e.response?.data?['message'] ?? e.message}');
    }
  }

  Future<void> updateLocation(double latitude, double longitude) async {
    try {
      await _dio.patch(_locationPath, data: {
        'latitude': latitude,
        'longitude': longitude,
      });
    } on DioException catch (e) {
      // Ошибку не пробрасываем, т.к. это фоновая операция
      print('!!! API Error updating location: $e');
    }
  }

  Future<bool> testDbConnection() async {
    try {
      final response = await _dio.get(_testDbPath);
      return response.statusCode == 200;
    } on DioException catch (e) {
      print('API Error during DB connection test: $e');
      return false;
    } catch (e) {
      print('Unexpected error during DB connection test: $e');
      return false;
    }
  }
}
