import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:shared_data/services/api_service.dart';

class LocationService {
  final ApiService _apiService;
  StreamSubscription<Position>? _positionStream;

  LocationService(this._apiService);

  Future<void> startLocationUpdates() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    _positionStream = Geolocator.getPositionStream().listen((Position position) {
      print('New position: ${position.latitude}, ${position.longitude}');
      _apiService.updateLocation(position.latitude, position.longitude);
    });
  }

  void stopLocationUpdates() {
    _positionStream?.cancel();
  }
}
