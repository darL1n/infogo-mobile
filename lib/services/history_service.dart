import 'package:dio/dio.dart';
import 'package:mobile/models/history_view_place.dart';
import 'package:mobile/models/place.dart';
import 'package:mobile/services/api_client.dart';
import 'package:mobile/storages/hive_storage.dart';

class HistoryService {
  final Dio _api = ApiClient.dio;

  Future<List<HistroyViewPlaceModel>> fetchHistoryFromServer() async {
    try {
      final response = await _api.get('places/history/', options: Options(extra: {"withAuth": true}));
      final List<dynamic> data = response.data['results'];
      print(data);
      final clearData =
          data.map((json) => HistroyViewPlaceModel.fromJson(json)).toList();
      return clearData;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PlaceShortModel>> fetchByIds(List<int> ids) async {
    try {
      if (ids.isEmpty) return [];

      final response = await _api.post('places/by-ids/', data: {'ids': ids});

      final List data = response.data['results'];
      return data.map((json) => PlaceShortModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  List<int> getLocalHistoryIds() {
    return HiveStorage.getViewHistoryIds();
  }

  void addToLocal(int placeId) {
    final current = getLocalHistoryIds();
    if (!current.contains(placeId)) {
      final updated = [placeId, ...current].take(20).toList(); // только 50 последних
      HiveStorage.saveViewHistoryIds(updated);
    }
  }

  void clearLocal() {
    HiveStorage.clearViewHistoryIds();
  }

  /// Синхронизация: локальные → сервер
  Future<List<HistroyViewPlaceModel>> syncLocalToServer() async {
    final localIds = getLocalHistoryIds();
    if (localIds.isEmpty) return [];

    final response = await _api.post(
      'places/history/bulk/',
      options: Options(extra: {"withAuth": true}),
      data: {'place_ids': localIds},
    );

    final List data = response.data['results'];
    clearLocal(); // 💾 очистка Hive
    return data.map((json) => HistroyViewPlaceModel.fromJson(json)).toList();
  }

  // 🔜 Здесь можно будет добавить:
  // - syncLocalToServer
  // - fetchHistoryFromServer
}
