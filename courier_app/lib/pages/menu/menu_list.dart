import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_ui/colors.dart';
import 'package:shared_ui/styles.dart';
import 'package:shared_data/models/order.dart';
import 'package:shared_data/models/order_status.dart';
import 'package:courier_app/pages/balance/balance_page.dart';
import 'package:courier_app/pages/menu/menu_item.dart';
import 'package:courier_app/pages/settings/settings_page.dart';
import 'package:shared_data/services/api_service.dart';
import 'package:courier_app/widgets/active_order_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:courier_app/providers/theme_provider.dart';
import 'package:courier_app/utils/animated_content_switcher.dart';
import 'package:courier_app/utils/navigator_helper.dart';
import 'package:courier_app/pages/learning/learning_page.dart';
import 'package:courier_app/pages/chat/chat_page.dart';
import 'package:courier_app/main.dart';
import 'package:shared_data/utils/status_helpers.dart';

class MenuList extends StatefulWidget {
  const MenuList({super.key});

  @override
  State<MenuList> createState() => _MenuListState();
}

class _MenuListState extends State<MenuList> with WidgetsBindingObserver {
  bool _isOnline = false;
  bool _isLoading = false;
  bool _isUpdatingStatus = false;
  Order? _activeOrder;

  Timer? _animationTimer;
  int _secondsWaited = 0;
  String _animatedDots = '';

  StreamSubscription<String>? _messageSubscription;

  List<String> get _menuButtonLabels => [
        'Баланс',
        _isOnline ? 'Уйти с линии' : 'Выйти на линию',
        'Чат с диспетчером',
        'Обучение',
        'Настройки',
      ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadInitialStatus();
    _messageSubscription = notificationService.onMessageStream.listen((orderId) {
      print("Получено уведомление для заказа $orderId, запрашиваю детали...");
      _fetchOrderById(orderId);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopAnimationTimer();
    _messageSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("Приложение возобновлено, выполняю умную перезагрузку...");
      _smartReload();
    }
  }

  void _startAnimationTimer() {
    _stopAnimationTimer();
    if (mounted) {
      setState(() => _secondsWaited = 0);
      _animationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _secondsWaited++;
            int dotCount = _secondsWaited % 4;
            _animatedDots = '.' * dotCount;
          });
        }
      });
    }
  }

  void _stopAnimationTimer() {
    _animationTimer?.cancel();
  }

  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _fetchOrderById(String orderId) async {
    if (!mounted) return;
    final order = await context.read<ApiService>().getOrderById(orderId);
    if (mounted) {
      setState(() {
        _activeOrder = order;
        _isOnline = true; // Если нам пришел заказ, значит мы онлайн
        _isLoading = false; // Снимаем флаг загрузки
        if (order != null) {
          _stopAnimationTimer();
        }
      });
    }
  }

  Future<void> _smartReload() async {
    if (!mounted) return;

    final api = context.read<ApiService>();
    Order? newOrder;

    try {
      final shouldBeOnline = await authStateService.getOnlineStatus();
      if (shouldBeOnline) {
          newOrder = await api.getActiveOrder();
      }
      if (mounted) {
        if (newOrder?.id != _activeOrder?.id || shouldBeOnline != _isOnline) {
          print("Обнаружены изменения. Обновляю UI.");
          setState(() {
            _isOnline = shouldBeOnline;
            _activeOrder = newOrder;
            if (_isOnline && _activeOrder == null) {
              _startAnimationTimer();
            } else {
              _stopAnimationTimer();
            }
          });
        } else {
          print("Изменений нет. UI не требует обновления.");
        }
      }
    } catch (e) {
      print("Ошибка во время умной перезагрузки: $e");
    }
  }

  Future<void> _loadInitialStatus() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      await _smartReload();
    } catch (e) {
      if (mounted) _showError('Ошибка загрузки статуса: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleOnlineStatus() async {
    if (_activeOrder != null && _isOnline) {
      _showError('Сначала завершите активный заказ!');
      return;
    }
    if (_isLoading) return;

    final newStatus = !_isOnline;

    setState(() => _isLoading = true);

    try {
      await context.read<ApiService>().updateOnlineStatus(newStatus);
      await authStateService.setOnlineStatus(newStatus);

      setState(() {
        _isOnline = newStatus;
        if (_isOnline) {
          _startAnimationTimer();
        } else {
          _stopAnimationTimer();
        }
      });
    } catch (e) {
      if (mounted) _showError('Ошибка смены статуса: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onStatusChange(OrderStatus newStatus) async {
    if (_activeOrder == null || _isUpdatingStatus) return;
    setState(() => _isUpdatingStatus = true);
    try {
      await context.read<ApiService>().updateOrderStatus(_activeOrder!.id, newStatus);

      if (newStatus == OrderStatus.delivered) {
        await _smartReload();
      } else {
        await _fetchOrderById(_activeOrder!.id.toString());
      }
    } catch (e) {
      if (mounted) _showError('Ошибка обновления статуса заказа: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isUpdatingStatus = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            Widget contentWidget;
            bool showAnimatedContent = true;

            if (_isLoading) {
              contentWidget = Padding(
                padding: const EdgeInsets.symmetric(vertical: 48.0),
                child: Center(child: CircularProgressIndicator(color: primaryColor(context))),
              );
            }
            else if (_activeOrder != null) {
              _stopAnimationTimer();

              final buttonText = getButtonTextForCourier(_activeOrder!.status);

              if(buttonText.isNotEmpty) {
                contentWidget = ActiveOrderCard(
                  activeOrder: _activeOrder!,
                  onStatusChange: _onStatusChange,
                  isLocating: _isUpdatingStatus,
                );
              } else {
                 contentWidget = Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48.0),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Обработка заказа...", style: primaryTextStyle(context)),
                          const SizedBox(height: 10),
                          CircularProgressIndicator(color: primaryColor(context)),
                        ],
                      ),
                    ),
                  );
              }
            }
            else if (_isOnline) {
              contentWidget = Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Поиск заказа',
                            style: primaryTextStyle(context).copyWith(fontSize: 22),
                          ),
                          Container(
                            width: 30,
                            child: Text(
                              _animatedDots,
                              style: primaryTextStyle(context).copyWith(fontSize: 22),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDuration(_secondsWaited),
                        style: listItem2Style(context).copyWith(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              );
            }
            else {
              showAnimatedContent = false;
              contentWidget = Container();
            }

            return AnimatedContentSwitcher(
              showContent: showAnimatedContent,
              orderWidget: contentWidget,
            );
          },
        ),
        Expanded(child: _listButtons()),
      ],
    );
  }

  Widget _listButtons() {
     return ListView.separated(
      itemCount: _menuButtonLabels.length,
      padding: const EdgeInsets.all(16.0),
      separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 10),
      itemBuilder: (BuildContext context, int index) {
        return MenuItem(
          menuButtonText: _menuButtonLabels[index],
          onTap: () {
            if (_isLoading && index == 1) return;
            if (index == 0) {
              NavigatorHelper.navigateTo(context, const BalancePage());
            } else if (index == 1) {
              _toggleOnlineStatus();
            } else if (index == 2) {
              NavigatorHelper.navigateTo(
                context,
                ChatPage(orderNumber: _activeOrder?.orderNumber),
              );
            } else if (index == 3) {
              NavigatorHelper.navigateTo(context, LearningPage());
            } else if (index == 4) {
              NavigatorHelper.navigateTo(context, SettingsPage(activeOrder: _activeOrder));
            }
          },
        );
      },
    );
  }
}
