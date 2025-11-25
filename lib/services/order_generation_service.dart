import 'dart:math';
import '../models/order.dart';
import '../models/order_status.dart';
import '../models/order_type.dart';

class OrderGenerationService {
  final Random _random = Random();

  final List<String> randomName = const [
    'Вася Пупкин', 'Петя Залупкин', 'Саша Белый', 'Коля Смелый',
    'Маша Лютая', 'Глаша Чиканутая', 'Захар Трошин', 'Макар Блошин',
  ];
  final List<String> randomAdress = const [
    'ул. Пушкина, д. 10, кв. 3', 'пр. Ленина, д. 45, офис 201',
    'ул. Гагарина, д. 7, подъезд 2', 'пер. Солнечный, д. 11, кв. 89',
    'наб. Речная, д. 3, строение 1', 'ул. Кирова, д. 22, этаж 5',
    'б-р Строителей, д. 1, кв. 14', 'ул. Мира, д. 55, ТЦ "Заря", секция А',
  ];

  Order generateNewOrder(String orderNumber) {
    int nameIndex = _random.nextInt(randomName.length);
    int addressAIndex = _random.nextInt(randomAdress.length);
    int addressBIndex = _random.nextInt(randomAdress.length);
    double baseLat = 55.7558;
    double baseLon = 37.6176;
    OrderType randomType = _random.nextBool() ? OrderType.private : OrderType.point;

    return Order(
      customerName: randomName[nameIndex],
      addressA: randomAdress[addressAIndex], // Генерируем адрес A
      addressB: randomAdress[addressBIndex],
      latA: baseLat + (_random.nextDouble() - 0.5) / 10, // Случайное смещение
      lonA: baseLon + (_random.nextDouble() - 0.5) / 10,
      latB: baseLat + (_random.nextDouble() - 0.5) / 10,
      lonB: baseLon + (_random.nextDouble() - 0.5) / 10,
      orderNumber: orderNumber,
      completionTime: DateTime.now(),
      status: OrderStatus.accepted,
      type: randomType,
    );
  }
}