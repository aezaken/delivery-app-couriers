import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_data/models/courier.dart';
import 'package:shared_data/models/order.dart';
import 'package:shared_data/services/api_service.dart';
import 'package:geolocator/geolocator.dart';
import '../services/courier_service.dart';
import '../utils/courier_sorter.dart';

class AssignCourierPage extends StatefulWidget {
  final Order order;

  const AssignCourierPage({super.key, required this.order});

  @override
  State<AssignCourierPage> createState() => _AssignCourierPageState();
}

class _AssignCourierPageState extends State<AssignCourierPage> {
  late Future<List<Courier>> _couriersFuture;

  @override
  void initState() {
    super.initState();
    _fetchCouriers();
  }

  void _fetchCouriers() {
    final courierService = context.read<CourierService>();
    setState(() {
      _couriersFuture = courierService.getOnlineCouriers();
    });
  }

  Future<void> _assignCourier(Courier courier) async {
    final apiService = context.read<ApiService>();

    try {
      await apiService.assignCourier(widget.order.id, courier.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Курьер ${courier.fullName} назначен!')),
        );
        Navigator.of(context).pop();
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка назначения: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Назначить на заказ #${widget.order.orderNumber}'),
      ),
      body: FutureBuilder<List<Courier>>(
        future: _couriersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка загрузки курьеров: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Нет свободных курьеров в сети'));
          }

          final couriers = snapshot.data!;

          // Сортируем курьеров по расстоянию до точки А с использованием утилиты
          CourierSorter.sortCouriersByDistance(widget.order, couriers);

          return ListView.builder(
            itemCount: couriers.length,
            itemBuilder: (context, index) {
              final courier = couriers[index];
              String? distanceString;

              // Расчет расстояния с использованием утилиты
              distanceString = CourierSorter.calculateDistanceToString(widget.order, courier);

              return ListTile(
                title: Text(courier.fullName),
                subtitle: distanceString != null ? Text(distanceString) : null,
                leading: const Icon(Icons.person_outline),
                onTap: () => _assignCourier(courier),
              );
            },
          );
        },
      ),
    );
  }
}
