class MapClickPlace {
  final int id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double distanceM;

  MapClickPlace({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distanceM,
  });

  factory MapClickPlace.fromJson(Map<String, dynamic> json) {
    return MapClickPlace(
      id: json['id'] as int,
      name: json['name'] as String,
      address: (json['address'] ?? '') as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      distanceM: (json['distance_m'] as num).toDouble(),
    );
  }
}

class MapClickGroup {
  final String address;
  final int count;
  final List<MapClickPlace> places;

  MapClickGroup({
    required this.address,
    required this.count,
    required this.places,
  });

  factory MapClickGroup.fromJson(Map<String, dynamic> json) {
    final placesJson = (json['places'] as List<dynamic>? ?? []);
    return MapClickGroup(
      address: (json['address'] ?? '') as String,
      count: json['count'] as int,
      places: placesJson
          .map((e) => MapClickPlace.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class MapClickResult {
  final double pointLat;
  final double pointLng;
  final double radiusM;
  final List<MapClickGroup> groups;

  MapClickResult({
    required this.pointLat,
    required this.pointLng,
    required this.radiusM,
    required this.groups,
  });

  factory MapClickResult.fromJson(Map<String, dynamic> json) {
    final groupsJson = (json['groups'] as List<dynamic>? ?? []);
    return MapClickResult(
      pointLat: (json['point_lat'] as num).toDouble(),
      pointLng: (json['point_lng'] as num).toDouble(),
      radiusM: (json['radius_m'] as num).toDouble(),
      groups: groupsJson
          .map((e) => MapClickGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
