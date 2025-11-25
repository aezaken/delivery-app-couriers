
import 'package:apps/design/colors.dart';
import 'package:apps/pages/balance/balance_page.dart';
import 'package:apps/pages/menu/menu_item.dart';
import 'package:apps/pages/settings/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/order.dart';
import '../../models/order_status.dart';
import '../../utils/animated_content_switcher.dart';
import '../../utils/navigator_helper.dart';
import '../../utils/order_history_manager.dart';
import '../../widgets/active_order_card.dart';
import '../learning/learning_page.dart';
import 'package:apps/pages/chat/chat_page.dart';
import '../../main.dart';
import '../../services/order_generation_service.dart';

class MenuList extends StatefulWidget {
  const MenuList({super.key});

  @override
  State<MenuList> createState() => _MenuListState();
}

class _MenuListState extends State<MenuList> with TickerProviderStateMixin {
  bool isOnline = false;
  bool isLoading = false;
  bool isTransitioning = false;
  bool isLocating = false;

  Order? activeOrder;

  final OrderGenerationService _orderGenerator = OrderGenerationService();
  final double _validationDistance = 50.0;

  List<String> menuButtonLabels = [
    'Баланс',
    'Выйти на линию',
    'Чат с диспетчером',
    'Обучение',
    'Настройки',
  ];

  @override
  void initState() {
    super.initState();
    _loadOnlineStatus(); // ✅ Загружаем статус при старте
  }

  Future<void> _loadOnlineStatus() async {
    // Загружаем сохраненный статус из SharedPreferences
    bool savedStatus = await authStateService.getOnlineStatus();
    setState(() {
      isOnline = savedStatus;
      // Также нужно обновить текст кнопки при загрузке статуса
      menuButtonLabels[1] = isOnline ? 'Уйти с линии' : 'Выйти на линию';
    });
  }

  void _saveOrderToHistory(Order order) {
    final completedOrder = Order(
      customerName: order.customerName,
      addressA: order.addressA,
      addressB: order.addressB,
      latA: order.latA, // ✅ Добавлены координаты
      lonA: order.lonA, // ✅ Добавлены координаты
      latB: order.latB, // ✅ Добавлены координаты
      lonB: order.lonB,
      orderNumber: order.orderNumber,
      completionTime: DateTime.now(),
      status: OrderStatus.delivered,
    );
    Provider.of<OrderHistoryManager>(context, listen: false).addOrder(completedOrder);
  }

  Future<void> _completeOrderAndSearchNext() async {
    await authStateService.setOnlineStatus(true);
    if (activeOrder != null) {
      _saveOrderToHistory(activeOrder!);
    }
    final orderHistoryManager = Provider.of<OrderHistoryManager>(context, listen: false);
    String nextOrderNumber = orderHistoryManager.nextOrderNumber.toString();
    activeOrder = _orderGenerator.generateNewOrder(nextOrderNumber);

    setState(() {
      isLoading = true;
      isTransitioning = true;
    });

    await Future.delayed(Duration(seconds: 2));
    if (!mounted) return;

    setState(() {
      isLoading = false;
      isTransitioning = false;
    });

    if (activeOrder != null) {
      await notificationService.showNewOrderNotification(activeOrder!.orderNumber);
    }
  }

  void _onLineToggle() async {
    if (isLoading) {
      setState(() {
        isLoading = false;
        isOnline = false;
        isTransitioning = false;
        activeOrder = null; // Очищаем активный заказ
        menuButtonLabels[1] = 'Выйти на линию';
      });
      await authStateService.setOnlineStatus(false);
      return;
    }
    if (isOnline) {
      if (activeOrder != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Сначала завершите активный заказ!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      setState(() {
        isOnline = false;
        menuButtonLabels[1] = 'Выйти на линию';
      });
      await authStateService.setOnlineStatus(false);
    } else {
      // Логика первого выхода на линию (поиск заказа)
      final orderHistoryManager = Provider.of<OrderHistoryManager>(context, listen: false);
      String nextOrderNumber = orderHistoryManager.nextOrderNumber.toString();

      // ✅ Инициализируем activeOrder здесь через сервис генерации
      activeOrder = _orderGenerator.generateNewOrder(nextOrderNumber);


      setState(() {
        isLoading = true;
        isTransitioning = true;
        menuButtonLabels[1] = 'Уйти с линии';
      });
      await authStateService.setOnlineStatus(true);
      await Future.delayed(Duration(seconds: 2));
      if (!mounted) return;

      if (isLoading) {
        setState(() {
          isLoading = false;
          isOnline = true;
          isTransitioning = false;
        });
        await authStateService.setOnlineStatus(true);
        if (activeOrder != null) {
          await notificationService.showNewOrderNotification(activeOrder!.orderNumber);
        }
      }
    }
  }
  void _updateOrderStatus(OrderStatus newStatus) async {
    if (activeOrder == null || isLocating) return;
    setState(() {
      isLocating = true; // ✅ Начинаем поиск локации
    });

    // Определяем координаты для валидации в зависимости от НОВОГО статуса
    double targetLat, targetLon;
    String targetAddressName;

    if (newStatus == OrderStatus.arrived) {
      // Валидируем точку A (Сбор заказа)
      targetLat = activeOrder!.latA;
      targetLon = activeOrder!.lonA;
      targetAddressName = "точки сбора";
    } else if (newStatus == OrderStatus.delivered) {
      // Валидируем точку B (Доставка)
      targetLat = activeOrder!.latB;
      targetLon = activeOrder!.lonB;
      targetAddressName = "адреса доставки";
    } else {
      // Для других статусов (например, pickedUp) пока валидация не нужна
      _updateStatusInState(newStatus);
      return;
    }

    // 1. Получаем текущее местоположение курьера
    final position = await locationService.getCurrentLocation();

    setState(() {
      isLocating = false; // ✅ Заканчиваем поиск локации
    });
    if (position == null) {
      // Если не удалось получить локацию (нет GPS/разрешений), просто выходим
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Невозможно определить местоположение. Проверьте GPS/разрешения.'), backgroundColor: Colors.orange));
      return;
    }

    // 2. Рассчитываем расстояние до целевой точки
    final distance = locationService.calculateDistance(
        position.latitude, position.longitude,
        targetLat, targetLon
    );

    // 3. Проверяем расстояние
    if (distance <= _validationDistance) {
      // Курьер достаточно близко, меняем статус
      _updateStatusInState(newStatus);
    } else {
      // Курьер далеко, показываем ошибку
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Вы находитесь в ${distance.toStringAsFixed(0)} метрах от $targetAddressName. Нужно быть ближе $_validationDistance м.'),
            backgroundColor: Colors.red
        ),
      );
    }
  }

  // Вспомогательный метод для обновления состояния (чтобы не дублировать код)
  void _updateStatusInState(OrderStatus newStatus) {
    if (newStatus == OrderStatus.delivered) {
      _completeOrderAndSearchNext();
      return;
    }
    setState(() {
      activeOrder!.status = newStatus;
    });
    // В будущем: отправка статуса на сервер
  }

  @override
  Widget build(BuildContext context) {
    return _mainContent();
  }

  Widget _mainContent() {
    // Определяем, что показывать в зависимости от isLoading и activeOrder
    return Column(
      children: [
        // ✅ ДОБАВЛЕНО: Оборачиваем AnimatedContentSwitcher в Consumer, чтобы он перестраивался при смене темы
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            // Мы должны пересчитать contentWidget здесь, чтобы он использовал новый контекст
            Widget updatedContentWidget;

            if (isLoading) {
              updatedContentWidget = Container(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator(color: primaryColor(context))),
              );
            } else if (activeOrder != null) {
              updatedContentWidget = ActiveOrderCard(
                activeOrder: activeOrder!,
                onCompleteOrder: _completeOrderAndSearchNext,
                onStatusChange: _updateOrderStatus,
                isLocating: isLocating,
              );
            } else {
              updatedContentWidget = Container();
            }


            return AnimatedContentSwitcher(
              showContent: isOnline || isLoading,
              isLoading: isLoading,
              orderWidget: updatedContentWidget, // Используем обновленный виджет
            );
          },
        ),
        Expanded(child: _listButtons()),
      ],
    );
  }

  Widget _listButtons() {
    return ListView.separated(
      itemCount: menuButtonLabels.length,
      padding: EdgeInsets.all(16.0),
      separatorBuilder: (BuildContext context, int index) {
        return SizedBox(height: 10);
      },
      itemBuilder: (BuildContext context, int index) {
        return MenuItem(
          menuButtonText: menuButtonLabels[index],
          onTap: () {
            if (index == 0) {
              NavigatorHelper.navigateTo(context, BalancePage());
            } else if (index == 1) {
              _onLineToggle();
            } else if (index == 2) {
              NavigatorHelper.navigateTo(
                context,
                ChatPage(orderNumber: activeOrder?.orderNumber),
              );
            } else if (index == 3) {
              NavigatorHelper.navigateTo(context, LearningPage());
            } else if (index == 4) {
              NavigatorHelper.navigateTo(context, SettingsPage());
            }
          },
        );
      },
    );
  }
}
