class Courier {
  final int id;
  final String? phone;
  final String fullName;
  final double? latitude;
  final double? longitude;

  Courier({
    required this.id, 
    this.phone, 
    required this.fullName, 
    this.latitude, 
    this.longitude
  });

  factory Courier.fromJson(Map<String, dynamic> json) {
    return Courier(
      id: int.parse(json['id'].toString()),
      phone: json['phoneNumber'] as String?,
      fullName: json['fullName'] as String? ?? 'Имя не указано',
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
    );
  }
}
