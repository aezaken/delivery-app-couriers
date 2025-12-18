import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class CourierLocationUpdate {
  final int courierId;
  final double latitude;
  final double longitude;

  CourierLocationUpdate({
    required this.courierId,
    required this.latitude,
    required this.longitude,
  });

  factory CourierLocationUpdate.fromJson(Map<String, dynamic> json) {
    return CourierLocationUpdate(
      courierId: json['courierId'] as int,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}

class WebSocketService {
  WebSocketChannel? _channel;
  final _controller = StreamController<CourierLocationUpdate>.broadcast();

  Stream<CourierLocationUpdate> get stream => _controller.stream;

  void connect() {
    final baseUrl = dotenv.env['API_URL']?.replaceFirst('http', 'ws') ?? 'ws://localhost:3000';
    final url = Uri.parse(baseUrl);

    try {
      _channel = WebSocketChannel.connect(url);
      print('[WEBSOCKET] Подключение к $url...');

      _channel!.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message);
            if (data['type'] == 'COURIER_LOCATION_UPDATE') {
              final update = CourierLocationUpdate.fromJson(data['payload']);
              _controller.add(update);
            }
          } catch (e) {
            print('[WEBSOCKET] Ошибка парсинга сообщения: $e');
          }
        },
        onDone: () {
          print('[WEBSOCKET] Соединение закрыто. Попытка переподключения через 5 секунд...');
          _reconnect();
        },
        onError: (error) {
          print('[WEBSOCKET] Ошибка: $error. Попытка переподключения через 5 секунд...');
          _reconnect();
        },
      );
    } catch (e) {
      print('[WEBSOCKET] Не удалось подключиться: $e');
    }
  }

  void _reconnect() {
    _channel?.sink.close();
    Future.delayed(const Duration(seconds: 5), connect);
  }

  void dispose() {
    _controller.close();
    _channel?.sink.close();
    print('[WEBSOCKET] Сервис остановлен.');
  }
}
