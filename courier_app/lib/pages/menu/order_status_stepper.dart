import 'package:flutter/material.dart';
import 'package:shared_data/models/order_status.dart';
import 'package:shared_data/utils/status_helpers.dart';
import 'package:shared_ui/colors.dart';
import 'package:shared_ui/styles.dart'; // Импортируем стили

class OrderStatusStepper extends StatelessWidget {
  final OrderStatus currentStatus;
  final Future<void> Function(OrderStatus) onStatusChange;
  final bool isLocating;

  const OrderStatusStepper({
    super.key,
    required this.currentStatus,
    required this.onStatusChange,
    required this.isLocating,
  });

  @override
  Widget build(BuildContext context) {
    if (isLocating) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor(context)),
          child: const SizedBox(
            width: 20,
            height: 20,
            child:
                CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
          ),
        ),
      );
    }

    final buttonText = getButtonTextForCourier(currentStatus);
    if (buttonText.isEmpty) {
      return Container();
    }

    final nextStatus = getNextStatusForCourier(currentStatus);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => onStatusChange(nextStatus),
        style: ElevatedButton.styleFrom(
          backgroundColor: nextStatus == OrderStatus.delivered
              ? Colors.green[700]
              : primaryColor(context),
        ),
        child: Text(
          buttonText,
          // --- ИСПРАВЛЕНИЕ: Используем стиль из shared_ui ---
          style: nextStatus == OrderStatus.delivered
              ? const TextStyle(color: Colors.white, fontWeight: FontWeight.w600) // Для зеленой кнопки оставляем белый
              : listItem1Style(context), // А для желтой берем наш консистентный стиль
        ),
      ),
    );
  }
}