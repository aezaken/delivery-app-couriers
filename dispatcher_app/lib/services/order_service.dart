import 'package:shared_data/models/order.dart';
import 'package:shared_data/services/api_service.dart';

class OrderService {
  final ApiService apiService;

  OrderService(this.apiService);

  Future<List<Order>> getAllOrders() {
    return apiService.getAllOrders();
  }

  Future<Order> createOrder({
    required String customerName,
    required String addressA,
    required String addressB,
  }) {
    return apiService.createOrder(
      customerName: customerName,
      addressA: addressA,
      addressB: addressB,
    );
  }

  Future<void> assignCourier(int orderId, int courierId) {
    return apiService.assignCourier(orderId, courierId);
  }
}
