import 'package:shared_data/models/order_status.dart';
import 'package:shared_data/utils/status_helpers.dart'; // <-- ИМПОРТ

class Order {
  final int id;
  final String customerName;
  final String addressA;
  final String addressB;
  OrderStatus status;
  final int? courierId;
  final DateTime? createdAt;

  final double? latA;
  final double? lonA;
  final double? latB;
  final double? lonB;
  String get orderNumber => id.toString();

  Order({
    required this.id,
    required this.customerName,
    required this.addressA,
    required this.addressB,
    required this.status,
    this.courierId,
    this.createdAt,
    this.latA,
    this.lonA,
    this.latB,
    this.lonB,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: int.parse(json['id'].toString()),
      customerName: json['customerName'] as String? ?? 'Имя не указано',
      addressA: json['addressA'] as String? ?? 'Адрес A не указан',
      addressB: json['addressB'] as String? ?? 'Адрес Б не указан',
      status: statusFromString(json['status'] ?? 'unknown'),
      courierId: json['courierId'] != null ? int.parse(json['courierId'].toString()) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      latA: json['latA'] as double?,
      lonA: json['lonA'] as double?,
      latB: json['latB'] as double?,
      lonB: json['lonB'] as double?,
    );
  }
}
