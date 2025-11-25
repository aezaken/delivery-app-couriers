import 'order_status.dart';
import 'order_type.dart';

class Order {
  final String customerName;
  final String addressA;
  final String addressB;
  final double latA; // Широта точки A
  final double lonA; // Долгота точки A
  final double latB; // Широта точки B
  final double lonB; // Долгота точки B
  final String orderNumber;
  final DateTime completionTime;

  OrderStatus status;

  OrderType type;

  Order({
    required this.customerName,
    required this.addressA,
    required this.addressB,
    required this.latA,
    required this.lonA,
    required this.latB,
    required this.lonB,
    required this.orderNumber,
    required this.completionTime,
    this.status = OrderStatus.accepted,// По умолчанию "принят"
    this.type = OrderType.private,
  });
}