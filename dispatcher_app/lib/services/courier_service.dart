import 'package:shared_data/models/courier.dart';
import 'package:shared_data/services/api_service.dart';

class CourierService {
  final ApiService apiService;

  CourierService(this.apiService);

  Future<List<Courier>> getOnlineCouriers() {
    return apiService.getOnlineCouriers();
  }
}
