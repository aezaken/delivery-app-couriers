import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:shared_data/models/order.dart';
import '../../../utils/order_history_manager.dart';

class HistoryList extends StatefulWidget {
  const HistoryList({super.key});

  @override
  State<StatefulWidget> createState() => _HistoryListState();
}

class _HistoryListState extends State<HistoryList> {
  @override
  Widget build(BuildContext context) {
    final orderHistory = Provider.of<OrderHistoryManager>(context).history;
    return _buildContent(orderHistory);
  }

  Widget _buildContent(List<Order> historyList) {
    if (historyList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long, size: 60.0, color: Colors.grey[400]),
              const SizedBox(height: 16.0),
              Text(
                'У Вас ещё нет выполненных заказов',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18.0, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    } else {
      return ListView.separated(
        itemCount: historyList.length,
        itemBuilder: (context, index) {
          final order = historyList[index];
          // --- ИСПРАВЛЕНИЕ: Безопасная обработка nullable-даты ---
          final formattedTime = order.createdAt != null
              ? DateFormat('dd.MM.yyyy HH:mm').format(order.createdAt!)
              : '--:--';

          return ListTile(
            title: Text('Заказ #${order.orderNumber}'),
            subtitle: Text('${order.customerName}\n${order.addressA}'),
            trailing: Text(formattedTime),
            isThreeLine: true,
          );
        },
        separatorBuilder: (context, index) => const Divider(height: 1),
      );
    }
  }
}
