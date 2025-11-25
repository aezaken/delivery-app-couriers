import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initializePlatformNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('launch_background'); // Замените 'app_icon' на имя вашего значка в mipmap/drawable

    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Логика обработки нажатия на уведомление, когда приложение активно
        debugPrint('Notification payload: ${response.payload}');
      },
    );
  }

  // Метод для показа уведомления о новом заказе
  Future<void> showNewOrderNotification(String orderNumber) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'order_channel_id', // ID канала
      'Order Notifications', // Имя канала
      channelDescription: 'Channel for new order notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // ID уведомления (можно использовать уникальный ID заказа)
      'Новый заказ найден!', // Заголовок
      'Заказ №$orderNumber ожидает выполнения. Откройте приложение.', // Тело уведомления
      platformChannelSpecifics,
      payload: orderNumber,
    );
  }
}