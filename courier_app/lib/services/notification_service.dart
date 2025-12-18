import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // --- ИЗМЕНЕНИЕ: Stream теперь передает только ID заказа (String) ---
  final _messageStreamController = StreamController<String>.broadcast();
  Stream<String> get onMessageStream => _messageStreamController.stream;

  Future<void> initializePlatformNotifications() async {
    await _firebaseMessaging.requestPermission();

    final fcmToken = await getToken();
    print("FCM Token: $fcmToken");

    _setupForegroundMessageHandler();
    _setupInteractedMessage();

    // Проверяем, было ли приложение открыто по нажатию на уведомление в "убитом" состоянии
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
  }

  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  // --- ИЗМЕНЕНИЕ: Выносим логику обработки в отдельный метод ---
  void _handleMessage(RemoteMessage message) {
    print('Handling message: ${message.data}');
    final orderId = message.data['orderId'] as String?;
    if (orderId != null) {
      _messageStreamController.add(orderId);
    }
  }

  void _setupForegroundMessageHandler() {
    FirebaseMessaging.onMessage.listen(_handleMessage);
  }

  void _setupInteractedMessage() {
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void dispose() {
    _messageStreamController.close();
  }
}
