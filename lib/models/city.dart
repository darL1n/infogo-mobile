import 'package:hive/hive.dart';

part 'city.g.dart';

@HiveType(typeId: 3) // ⚠️ Убедись, что у каждого HiveType свой уникальный `typeId`
class CityModel {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double latitude;

  @HiveField(3)
  final double longitude;

  CityModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
    );
  }
}


