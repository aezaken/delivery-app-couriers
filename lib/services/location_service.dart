import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

class LocationService {
  // Проверяет и запрашивает разрешения на геолокацию
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Проверяем, включена ли служба геолокации
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // return Future.error('Location services are disabled.');
      // Предлагаем пользователю включить GPS
      await Geolocator.openLocationSettings();
      return null;
    }

    // Проверяем статус разрешения
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // return Future.error('Location permissions are denied');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // return Future.error('Location permissions are permanently denied, we cannot request permissions.');
      return null;
    }

    // Если все разрешения в порядке, получаем текущую позицию
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
    );
  }

  // Метод для расчета расстояния между двумя координатами (в метрах)
  double calculateDistance(double startLat, double startLon, double endLat, double endLon) {
    return Geolocator.distanceBetween(startLat, startLon, endLat, endLon);
  }
}