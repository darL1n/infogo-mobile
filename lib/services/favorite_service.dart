import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile/models/favorite_place.dart';
import 'package:mobile/models/place.dart';
import 'package:mobile/services/api_client.dart';
import 'package:mobile/storages/hive_storage.dart';

class FavoriteService {
  final Dio _api = ApiClient.dio;

  /// Получить избранное с сервера
  Future<List<FavoritePlaceModel>> fetchFavoritesFromServer() async {
  try {
    final response = await _api.get(
      'places/favorites/',
      options: Options(extra: {"withAuth": true}),
    );

    final body = response.data;
    debugPrint('⭐ fetchFavoritesFromServer body type: ${body.runtimeType}');

    dynamic payload = body;

    // если ответ вида { "results": [...] }
    if (payload is Map<String, dynamic> && payload['results'] != null) {
      payload = payload['results'];
    }

    if (payload is! List) {
      debugPrint('❌ favoritesFromServer: ожидался List, а пришло ${payload.runtimeType}');
      return [];
    }

    final list = (payload)
        .whereType<Map<String, dynamic>>() // отбрасываем мусор
        .cast<Map<String, dynamic>>()
        .map((json) {
          // если у тебя в FavoritePlaceModel.fromJson внутри жёсткий cast для place,
          // можно подстраховаться и тут:
          final place = json['place'];
          if (place == null || place is! Map<String, dynamic>) {
            debugPrint('⚠️ пропускаем favorite без нормального place: $json');
            return null;
          }
          return FavoritePlaceModel.fromJson(json);
        })
        .whereType<FavoritePlaceModel>() // убираем null
        .toList();

    debugPrint('✅ favoritesFromServer parsed: ${list.length}');
    return list;
  } catch (e, st) {
    debugPrint('❌ fetchFavoritesFromServer error: $e\n$st');
    return [];
  }
}


  Future<List<PlaceShortModel>> fetchByIds(List<int> ids) async {
  try {
    if (ids.isEmpty) return [];

    final response = await _api.post(
      'places/by-ids/',
      data: {'ids': ids},
    );

    final body = response.data;
    debugPrint('⭐ fetchByIds body type: ${body.runtimeType}');

    dynamic payload = body;

    // если { "results": [...] }
    if (payload is Map<String, dynamic> && payload['results'] != null) {
      payload = payload['results'];
    }

    if (payload is! List) {
      debugPrint('❌ fetchByIds: ожидался List, а пришло ${payload.runtimeType}');
      return [];
    }

    final list = (payload)
        .whereType<Map<String, dynamic>>()
        .cast<Map<String, dynamic>>()
        .map((json) => PlaceShortModel.fromJson(json))
        .toList();

    debugPrint('✅ fetchByIds parsed: ${list.length}');
    return list;
  } catch (e, st) {
    debugPrint('❌ fetchByIds error: $e\n$st');
    return [];
  }
}


  /// Добавить на сервер
  Future<void> addToServer(int placeId) async {
    await _api.post('places/favorites/', data: {'place_id': placeId}, options: Options(extra: {"withAuth": true}));
  }

  /// Удалить с сервера
  Future<void> removeFromServer(int placeId) async {
    await _api.delete('places/favorites/$placeId/', options: Options(extra: {"withAuth": true}));
  }

  List<int> getLocalFavorites() {
    return HiveStorage.getFavoriteIds();
  }

  void addToLocal(int placeId) {
    final current = getLocalFavorites();
    if (!current.contains(placeId)) {
      HiveStorage.saveFavoriteIds([...current, placeId]);
    }
  }

  void removeFromLocal(int placeId) {
    final current = getLocalFavorites();
    HiveStorage.saveFavoriteIds(current.where((id) => id != placeId).toList());
  }

  void clearLocal() {
    HiveStorage.clearFavoriteIds();
  }

  /// Синхронизация: локальные → сервер
  Future<List<FavoritePlaceModel>> syncLocalToServer() async {
  final localIds = getLocalFavorites();
  if (localIds.isEmpty) return [];

  try {
    final response = await _api.post(
      'places/favorites/bulk/',
      options: Options(extra: {"withAuth": true}),
      data: {'place_ids': localIds},
    );

    final body = response.data;
    debugPrint('⭐ syncLocalToServer body type: ${body.runtimeType}');

    dynamic payload = body;
    if (payload is Map<String, dynamic> && payload['results'] != null) {
      payload = payload['results'];
    }

    if (payload is! List) {
      debugPrint('❌ syncLocalToServer: ожидался List, а пришло ${payload.runtimeType}');
      clearLocal();
      return [];
    }

    final list = (payload)
        .whereType<Map<String, dynamic>>()
        .cast<Map<String, dynamic>>()
        .map((json) {
          final place = json['place'];
          if (place == null || place is! Map<String, dynamic>) {
            debugPrint('⚠️ пропускаем favorite без нормального place: $json');
            return null;
          }
          return FavoritePlaceModel.fromJson(json);
        })
        .whereType<FavoritePlaceModel>()
        .toList();

    clearLocal();
    debugPrint('✅ syncLocalToServer parsed: ${list.length}');
    return list;
  } catch (e, st) {
    debugPrint('❌ syncLocalToServer error: $e\n$st');
    // локальные лучше не трогать, пусть останутся
    return [];
  }
}

}
