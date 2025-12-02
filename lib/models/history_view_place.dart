import 'place.dart'; // 👈 Импортируешь свою уже готовую модель

class HistroyViewPlaceModel {
  final int id;
  final DateTime viewedAt;
  final PlaceShortModel place;

  HistroyViewPlaceModel({
    required this.id,
    required this.viewedAt,
    required this.place,
  });

  factory HistroyViewPlaceModel.fromJson(Map<String, dynamic> json) {
    return HistroyViewPlaceModel(
      id: json['id'],
      viewedAt: DateTime.parse(json['viewed_at']),
      place: PlaceShortModel.fromJson(json['place']),
    );
  }
}
