import 'package:flutter/material.dart';
import 'package:shared_data/models/order.dart';
import 'package:shared_data/models/order_status.dart';
import 'package:shared_ui/colors.dart';
import 'package:shared_ui/styles.dart';
import 'package:courier_app/pages/chat/chat_page.dart';
import 'package:courier_app/pages/menu/order_status_stepper.dart';
import 'package:courier_app/utils/navigator_helper.dart';

class ActiveOrderCard extends StatelessWidget {
  final Order activeOrder;
  // --- ИСПРАВЛЕНИЕ ТИПА: Указываем, что функция асинхронная ---
  final Future<void> Function(OrderStatus) onStatusChange;
  final bool isLocating;

  const ActiveOrderCard({
    Key? key,
    required this.activeOrder,
    required this.onStatusChange,
    required this.isLocating,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String currentAddressDisplay;
    String currentActionPrompt;

    if (activeOrder.status == OrderStatus.pickedUp) {
      currentAddressDisplay = activeOrder.addressB;
      currentActionPrompt = 'Доставка по адресу:';
    } else {
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
              Text(
                'Активный заказ',
                style: listItem1Style(context)
                    .copyWith(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                currentActionPrompt,
                style: listItem1Style(context).copyWith(
                  fontStyle: FontStyle.italic,
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
                isLocating: isLocating,
              ),
              const SizedBox(height: 10),
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
