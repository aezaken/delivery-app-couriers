import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_data/models/order.dart';
import 'package:shared_data/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:shared_data/utils/status_helpers.dart';
import 'assign_courier_page.dart';
import '../services/order_service.dart';

class OrdersListView extends StatefulWidget {
  const OrdersListView({super.key});

  @override
  State<OrdersListView> createState() => OrdersListViewState();
}

class OrdersListViewState extends State<OrdersListView> with AutomaticKeepAliveClientMixin {
  late Future<List<Order>> _ordersFuture;
  List<Order>? _cachedOrders;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  void fetchOrders() {
    final orderService = context.read<OrderService>();
    setState(() {
      _ordersFuture = orderService.getAllOrders();
    });
  }

  Future<void> _navigateToAssignCourier(Order order) async {
    if (order.courierId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('На этот заказ уже назначен курьер!')),
      );
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => AssignCourierPage(order: order)),
    );
    fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      body: FutureBuilder<List<Order>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          // Показываем кэшированные данные во время загрузки
          if (snapshot.connectionState == ConnectionState.waiting) {
            if (_cachedOrders != null) {
              return _buildOrdersList(_cachedOrders!);
            }
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            // Показываем кэш при ошибке, если он есть
            if (_cachedOrders != null) {
              return _buildOrdersList(_cachedOrders!);
            }
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            _cachedOrders = null;
            return const Center(child: Text('Активных заказов нет'));
          }

          // Обновляем кэш только если данные изменились
          final newOrders = snapshot.data!;
          if (_cachedOrders == null || !_ordersEqual(_cachedOrders!, newOrders)) {
            _cachedOrders = newOrders;
          }

          return _buildOrdersList(_cachedOrders!);
        },
      ),
    );
  }

  bool _ordersEqual(List<Order> list1, List<Order> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].id != list2[i].id || 
          list1[i].status != list2[i].status ||
          list1[i].courierId != list2[i].courierId) {
        return false;
      }
    }
    return true;
  }

  Widget _buildOrdersList(List<Order> orders) {
    return RefreshIndicator(
      onRefresh: () async => fetchOrders(),
      child: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          final formattedTime = order.createdAt != null
              ? DateFormat('HH:mm dd.MM').format(order.createdAt!)
              : '--:--';

          return ListTile(
            title: Text('Заказ #${order.orderNumber} - ${order.customerName}'),
            subtitle: Text(
                '${order.addressA} -> ${order.addressB}\nСтатус: ${displayStatusForDispatcher(order.status)}'),
            trailing: Text(formattedTime),
            isThreeLine: true,
            onTap: () => _navigateToAssignCourier(order),
          );
        },
      ),
    );
  }
}
