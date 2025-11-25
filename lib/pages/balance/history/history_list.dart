import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/order.dart';
import '../../../utils/order_history_manager.dart';

class HistoryList extends StatefulWidget {
  const HistoryList({super.key});

  @override
  State<StatefulWidget> createState() => _HistoryListState();
}

class _HistoryListState extends State<HistoryList> {
  @override
  Widget build(BuildContext context) {
    // Слушаем изменения в OrderHistoryManager
    final orderHistory = Provider.of<OrderHistoryManager>(context).history;

    return _buildContent(orderHistory);
  }

  Widget _buildContent(List<Order> historyList) {
    // Если список истории пуст, показываем заглушку
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
      // Если есть заказы, показываем список
      return ListView.separated( // Changed from CustomScrollView for simplicity
        itemCount: historyList.length,
        itemBuilder: (context, index) {
          final order = historyList[index];
          // Форматируем дату и время
          final formattedTime = DateFormat('dd.MM.yyyy HH:mm').format(order.completionTime);

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