import 'package:geolocator/geolocator.dart';
import 'package:shared_data/models/courier.dart';
import 'package:shared_data/models/order.dart';

class CourierSorter {
  static void sortCouriersByDistance(Order order, List<Courier> couriers) {
    if (order.latA == null || order.lonA == null) {
      return;
    }

    final orderLat = order.latA!;
    final orderLon = order.lonA!;

    couriers.sort((a, b) {
      // Если у курьера нет координат, ставим его в конец
      if (a.latitude == null || a.longitude == null) return 1;
      if (b.latitude == null || b.longitude == null) return -1;

      final distanceA = Geolocator.distanceBetween(orderLat, orderLon, a.latitude!, a.longitude!);
      final distanceB = Geolocator.distanceBetween(orderLat, orderLon, b.latitude!, b.longitude!);
      return distanceA.compareTo(distanceB);
    });
  }

  static String? calculateDistanceToString(Order order, Courier courier) {
    if (order.latA == null || order.lonA == null || 
        courier.latitude == null || courier.longitude == null) {
      return null;
    }

    final distanceInMeters = Geolocator.distanceBetween(
      order.latA!,
      order.lonA!,
      courier.latitude!,
      courier.longitude!
    );
    
    final distanceInKm = distanceInMeters / 1000;
    return '~${distanceInKm.toStringAsFixed(1)} км до точки А';
  }
  
  static List<Courier> getOnlineCouriersSortedByDistance(Order order, List<Courier> couriers) {
    final onlineCouriers = couriers.where((courier) => courier.latitude != null && courier.longitude != null).toList();
    sortCouriersByDistance(order, onlineCouriers);
    return onlineCouriers;
  }
}
