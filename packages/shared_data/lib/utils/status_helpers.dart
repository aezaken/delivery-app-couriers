import 'package:shared_data/models/order_status.dart';

// Единственный источник правды для парсинга статуса с бэкенда
OrderStatus statusFromString(String status) {
  switch (status) {
    case 'unassigned':
      return OrderStatus.unassigned;
    case 'assigned':
      return OrderStatus.assigned;
    case 'arrived':
      return OrderStatus.arrived;
    case 'pickedUp':
      return OrderStatus.pickedUp;
    case 'delivered':
      return OrderStatus.delivered;
    default:
      return OrderStatus.unknown;
  }
}

// Единственный источник правды для отображения статуса у диспетчера
String displayStatusForDispatcher(OrderStatus status) {
  switch (status) {
    case OrderStatus.unassigned:
      return 'Не назначен';
    case OrderStatus.assigned:
      return 'Назначен';
    case OrderStatus.arrived:
      return 'Прибыл за заказом (А)';
    case OrderStatus.pickedUp:
      return 'В пути к клиенту (Б)';
    case OrderStatus.delivered:
      return 'Доставлен';
    case OrderStatus.unknown:
    default:
      return 'Статус неизвестен';
  }
}

// ********** НОВАЯ ЛОГИКА ДЛЯ КУРЬЕРА **********

// Возвращает текст для кнопки курьера в зависимости от ТЕКУЩЕГО статуса
String getButtonTextForCourier(OrderStatus status) {
  switch (status) {
    case OrderStatus.assigned: // Если заказ только назначен
      return 'На месте (А)'; // Показываем кнопку "На месте (А)"
    case OrderStatus.arrived: // Если курьер уже на точке А
      return 'Забрал заказ'; // Показываем кнопку "Забрал заказ"
    case OrderStatus.pickedUp: // Если курьер забрал заказ
      return 'Завершить заказ'; // Показываем кнопку "Завершить"
    default:
      return ''; // Для всех остальных статусов кнопки нет
  }
}

// Возвращает СЛЕДУЮЩИЙ статус, который будет установлен после нажатия кнопки
OrderStatus getNextStatusForCourier(OrderStatus currentStatus) {
  switch (currentStatus) {
    case OrderStatus.assigned:
      return OrderStatus.arrived;
    case OrderStatus.arrived:
      return OrderStatus.pickedUp;
    case OrderStatus.pickedUp:
      return OrderStatus.delivered;
    default:
      return currentStatus; // Возвращаем текущий, если логика не определена
  }
}
