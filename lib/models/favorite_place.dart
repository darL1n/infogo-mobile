import 'place.dart'; // 👈 Импортируешь свою уже готовую модель

class FavoritePlaceModel {
  final int id;
  final DateTime addedAt;
  final PlaceShortModel place;

  FavoritePlaceModel({
    required this.id,
    required this.addedAt,
    required this.place,
  });

  factory FavoritePlaceModel.fromJson(Map<String, dynamic> json) {
    return FavoritePlaceModel(
      id: json['id'],
      addedAt: DateTime.parse(json['added_at']),
      place: PlaceShortModel.fromJson(json['place']),
    );
  }
}
