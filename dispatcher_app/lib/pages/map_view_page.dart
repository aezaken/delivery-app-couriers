import 'dart:async';

import 'package:dispatcher_app/services/websocket_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_data/models/courier.dart';

// Основной виджет карты
import 'package:yandex_maps_mapkit/yandex_map.dart';
// Для работы с картой и камерой
import 'package:yandex_maps_mapkit/mapkit.dart' as ymap;
// Для работы с изображениями
import 'package:yandex_maps_mapkit/image.dart' as yimage;

import '../services/courier_service.dart';

/// Страница с картой для отображения курьеров
///
/// Реализует все основные функции отображения курьеров на карте,
/// управления камерой и жизненным циклом карты.
/// Использует Yandex Maps MapKit 4.26.0-beta.
class MapViewPage extends StatefulWidget {
  const MapViewPage({super.key});

  @override
  State<MapViewPage> createState() => _MapViewPageState();
}

class _MapViewPageState extends State<MapViewPage> with AutomaticKeepAliveClientMixin {
  final WebSocketService _webSocketService = WebSocketService();
  late StreamSubscription<CourierLocationUpdate> _webSocketSubscription;
  
  ymap.Map? _map;

  // Ссылка на MapWindow для управления жизненным циклом карты
  // Ссылка на MapWindow больше не нужна, так как жизненный цикл управляется автоматически
  // ymap.MapWindow? _mapWindow;

  // Храним метки курьеров для управления ими
  final Map<int, ymap.PlacemarkMapObject> _courierPlacemarks = <int, ymap.PlacemarkMapObject>{};

  // Храним ссылку на иконку, так как MapKit использует слабые ссылки
  yimage.ImageProvider? _courierIcon;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeMap();
    _webSocketService.connect();
    _webSocketSubscription = 
        _webSocketService.stream.listen(_updateCourierPosition);
  }

  @override
  void dispose() {
    _webSocketSubscription.cancel();
    _webSocketService.dispose();
    
    // Правильная остановка работы карты
    // Вызов onStop() не требуется, так как он управляется автоматически виджетом YandexMap
    
    // Очищаем все ресурсы
    _courierPlacemarks.clear();
    
    super.dispose();
  }

  void _initializeMap() {
    // Загружаем иконку курьера из assets
    _loadCourierIcon();
  }

  Future<void> _loadCourierIcon() async {
    try {
      // Создаем провайдер изображения из assets
      final imageProvider = yimage.ImageProvider.fromImageProvider(const AssetImage('assets/icons/courier_icon.png'));
      
      if (mounted) {
        setState(() {
          _courierIcon = imageProvider;
        });
      }
    } on Exception catch (e) {
      _showError('Ошибка загрузки иконки курьера: $e');
    }
  }

  Future<void> _initializeCouriers() async {
    if (!mounted) return;

    try {
      final courierService = context.read<CourierService>();
      final couriers = await courierService.getOnlineCouriers();

      // Создаем метки для всех активных курьеров
      for (final courier in couriers) {
        if (courier.latitude != null && courier.longitude != null) {
          _addCourierPlacemark(courier);
        }
      }

      // Если есть курьеры, перемещаем камеру к первому из них
      if (couriers.isNotEmpty && couriers.first.latitude != null) {
        _moveCameraToLocation(
          couriers.first.latitude!,
          couriers.first.longitude!,
          zoom: 14
        );
      } else {
        // Если курьеров нет, устанавливаем начальную позицию камеры
        _moveCameraToLocation(43.797234, 131.952176, zoom: 12);
      }
    } on Exception catch (e) {
      _showError('Ошибка загрузки курьеров: $e');
    }
  }

  void _addCourierPlacemark(Courier courier) {
    if (_courierIcon == null || _map == null) {
      // Откладываем создание метки до тех пор, пока все необходимые ресурсы не будут готовы
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _addCourierPlacemark(courier);
        }
      });
      return;
    }

    // Создаем новую метку
    final placemark = _map!.mapObjects.addPlacemark()
      ..geometry = ymap.Point(latitude: courier.latitude!, longitude: courier.longitude!)
      ..setIcon(_courierIcon!)
      ..setText("Курьер ${courier.id}");

    // Сохраняем ссылку на метку для последующего обновления
    _courierPlacemarks[courier.id] = placemark;
  }

  void _updateCourierPosition(CourierLocationUpdate update) {
    if (!mounted || _map == null) return;

    // Если метка уже существует, обновляем ее позицию
    final existingPlacemark = _courierPlacemarks[update.courierId];
    if (existingPlacemark != null) {
      existingPlacemark.geometry = ymap.Point(
        latitude: update.latitude,
        longitude: update.longitude,
      );
    } else {
      // Если метки не было, создаем новую
      // Используем динамическую загрузку иконки, если основная не доступна
      final icon = _courierIcon ?? yimage.ImageProvider.fromImageProvider(const AssetImage('assets/icons/courier_icon.png'));
      
      final newPlacemark = _map!.mapObjects.addPlacemark()
        ..geometry = ymap.Point(latitude: update.latitude, longitude: update.longitude)
        ..setIcon(icon)
        ..setText("Курьер ${update.courierId}");
      
      _courierPlacemarks[update.courierId] = newPlacemark;
    }
  }

  void _moveCameraToLocation(double latitude, double longitude, {double zoom = 14}) {
    _map?.move(
      ymap.CameraPosition(
        ymap.Point(latitude: latitude, longitude: longitude),
        zoom: zoom,
        azimuth: 0,
        tilt: 0
      ),
    );
  }

  void _zoomIn() {
    _map?.moveWithAnimation(
      ymap.CameraPosition(
        _map!.cameraPosition.target,
        zoom: _map!.cameraPosition.zoom + 1,
        azimuth: _map!.cameraPosition.azimuth,
        tilt: _map!.cameraPosition.tilt
      ),
        ymap.Animation(ymap.AnimationType.Smooth, duration: 0.3,)
    );
  }

  void _zoomOut() {
    _map?.moveWithAnimation(
      ymap.CameraPosition(
        _map!.cameraPosition.target,
        zoom: _map!.cameraPosition.zoom -1,
        azimuth: _map!.cameraPosition.azimuth,
        tilt: _map!.cameraPosition.tilt
      ),
      ymap.Animation(ymap.AnimationType.Smooth, duration: 0.3,)
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Stack(
      children: [
        YandexMap(
          onMapCreated: (ymap.MapWindow mapWindow) {
            _map = mapWindow.map;
            
            // Уведомляем MapKit о начале работы
            // Вызов onStart() не требуется, так как он управляется автоматически виджетом YandexMap
            
            // Инициализируем начальное состояние
            _initializeCouriers();
          },
        ),
        
        // Кнопки управления масштабом
        Positioned(
          right: 16,
          top: 0,
          bottom: 0,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'zoom_in_button',
                  mini: true,
                  onPressed: _zoomIn,
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'zoom_out_button',
                  mini: true,
                  onPressed: _zoomOut,
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
