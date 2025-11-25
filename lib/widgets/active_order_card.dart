import 'package:flutter/material.dart';
import '../design/colors.dart';
import '../design/styles.dart';
import '../models/order.dart';
import '../models/order_status.dart'; // Нужен для OrderStatusStepper
import '../pages/chat/chat_page.dart';
import '../pages/menu/order_status_stepper.dart'; // Нужен для OrderStatusStepper
import '../utils/navigator_helper.dart';
import '../models/order_type.dart';

class ActiveOrderCard extends StatelessWidget {
  final Order activeOrder;
  final VoidCallback onCompleteOrder; // Вызывается, когда заказ завершен (статус Delivered)
  final ValueChanged<OrderStatus> onStatusChange; // Вызывается при смене статуса (На месте, Забрал)
  final bool isLocating;

  const ActiveOrderCard({
    Key? key,
    required this.activeOrder,
    required this.onCompleteOrder,
    required this.onStatusChange,
    required this.isLocating,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    String currentAddressDisplay;
    String currentActionPrompt;
    String typeLabel;
    IconData typeIcon;
    if (activeOrder.type == OrderType.private) {
      typeLabel = 'Частный заказ';
      typeIcon = Icons.person;
    } else {
      typeLabel = 'Заказ с точки';
      typeIcon = Icons.store;
    }

    if (activeOrder.status == OrderStatus.delivered) {
      // Заказ доставлен, но кнопка "Завершить" еще не нажата
      currentAddressDisplay = activeOrder.addressB;
      currentActionPrompt = 'Заказ успешно доставлен';
    } else if (activeOrder.status == OrderStatus.pickedUp) {
      // Курьер забрал заказ, теперь едет в точку Б
      currentAddressDisplay = activeOrder.addressB;
      currentActionPrompt = 'Доставка по адресу:';
    } else {
      // Принят или На месте (едет в точку А)
      currentAddressDisplay = activeOrder.addressA;
      currentActionPrompt = 'Забрать по адресу:';
    }
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
      child: Card(
        elevation: 4.0,
        color: primaryOpacyColor(context),
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Активный заказ',
                    style: listItem1Style(context).copyWith(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  // ✅ ДОБАВЛЯЕМ ОТОБРАЖЕНИЕ ТИПА ЗАКАЗА
                  Row(
                    children: [
                      Icon(typeIcon, size: 16, color: secondaryColor(context)),
                      SizedBox(width: 4),
                      Text(typeLabel, style: listItem2Style(context)),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                currentActionPrompt,
                style: listItem1Style(context).copyWith( // Используем Style 1
                  fontStyle: FontStyle.italic,
                  //decoration: TextDecoration.underline, // Добавляем подчеркивание
                  //decorationColor: secondaryColor(context), // Цвет подчеркивания
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Заказчик: ${activeOrder.customerName}',
                style: listItem1Style(context),
              ),
              Text(
                'Адрес: $currentAddressDisplay',
                style: listItem1Style(context),
              ),
              Text(
                'Номер заказа: ${activeOrder.orderNumber}',
                style: listItem1Style(context),
              ),

              const SizedBox(height: 20),

              OrderStatusStepper(
                currentStatus: activeOrder.status,
                onStatusChange: onStatusChange,
                onCompleteOrder: onCompleteOrder,
                isLocating: isLocating,
              ),

              const SizedBox(height: 10),

              // Кнопка Чата (остается отдельной)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    NavigatorHelper.navigateTo(
                      context,
                      ChatPage(orderNumber: activeOrder.orderNumber),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primaryColor(context)),
                  ),
                  child: Text(
                    'Чат',
                    style: TextStyle(color: primaryColor(context)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}