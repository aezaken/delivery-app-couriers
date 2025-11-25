
import 'package:flutter/material.dart';
import '../models/order.dart';

class OrderHistoryManager with ChangeNotifier {
  final List<Order> _history = [];
  int _nextOrderNumber = 1001;
  List<Order> get history => _history;

  void addOrder(Order order) {
    _history.insert(0, order); // Добавляем новый заказ в начало списка
    _nextOrderNumber++;
    notifyListeners(); // Уведомляем виджеты об изменении
  }
  int get nextOrderNumber => _nextOrderNumber;
}
