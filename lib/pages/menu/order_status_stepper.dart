import 'package:apps/design/colors.dart';
import 'package:apps/models/order_status.dart';
import 'package:flutter/material.dart';

class OrderStatusStepper extends StatelessWidget {
  final OrderStatus currentStatus;
  final ValueChanged<OrderStatus> onStatusChange;
  final VoidCallback onCompleteOrder;
  final bool isLocating;

  const OrderStatusStepper({
    super.key,
    required this.currentStatus,
    required this.onStatusChange,
    required this.onCompleteOrder,
    required this.isLocating,
  });

  @override
  Widget build(BuildContext context) {
    // Определяем, какую кнопку показать следующей
    Widget button;
    if (isLocating) {
      // Если идет поиск локации, показываем индикатор
      button = ElevatedButton(
        onPressed: () {}, // Отключаем кнопку
        style: ElevatedButton.styleFrom(backgroundColor: primaryColor(context)),
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        ),
      );
    }
    else {
      switch (currentStatus) {
        case OrderStatus.accepted:
          button = ElevatedButton(
            onPressed: () => onStatusChange(OrderStatus.arrived),
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor(context)),
            child: Text('Я на месте (A)', style: TextStyle(color: secondaryColor(context))),
          );
          break;
        case OrderStatus.arrived:
          button = ElevatedButton(
            onPressed: () => onStatusChange(OrderStatus.pickedUp),
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor(context)),
            child: Text('Заказ забрал', style: TextStyle(color: secondaryColor(context))),
          );
          break;
        case OrderStatus.pickedUp:
          button = ElevatedButton(
            onPressed: () => onStatusChange(OrderStatus.delivered), // Отправляем сигнал, что статус изменился
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
            child: Text('Заказ доставлен', style: TextStyle(color: Colors.white)),
          );
          break;
        case OrderStatus.delivered:
        // ✅ ИЗМЕНЕНИЕ: Это состояние больше не должно отображаться,
        // так как мы сразу уходим на поиск нового заказа.
        // Вернем пустой контейнер или кнопку-заглушку на всякий случай
          button = Container();
          break;
      }
    }

    return SizedBox(
      width: double.infinity,
      child: button,
    );
  }
}