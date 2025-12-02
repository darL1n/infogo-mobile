class MapPlaceMarkerModel {
  final int id;
  final String name;
  final double? latitude;
  final double? longitude;

  final double? rating;
  final int? ratingCount;
  final bool? isOpenNow;         // <- новое
  final bool? hasUpcomingEvents; // <- новое
  final DateTime? createdAt;     // <- пригодится для "Новые"

  MapPlaceMarkerModel({
    required this.id,
    required this.name,
    this.latitude,
    this.longitude,
    this.rating,
    this.ratingCount,
    this.isOpenNow,
    this.hasUpcomingEvents,
    this.createdAt,
  });

  factory MapPlaceMarkerModel.fromJson(Map<String, dynamic> json) {
    return MapPlaceMarkerModel(
      id: json['id'] as int,
      name: json['name'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble(),
      ratingCount: json['rating_count'] as int?,
      isOpenNow: json['is_open_now'] as bool?,
      hasUpcomingEvents: json['has_upcoming_events'] as bool?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}
