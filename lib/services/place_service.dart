import 'package:dio/dio.dart';
import 'package:mobile/models/map_place.dart';
import 'package:mobile/models/place.dart';
import 'package:mobile/models/place_detail.dart';
import 'package:mobile/models/place_filter.dart';
import 'package:mobile/models/map_place_marker.dart';
import 'package:mobile/models/map_place_card.dart';

import 'api_client.dart';

class PlaceService {
  final Dio _dio = ApiClient.dio;

  Future<List<PlaceModel>> fetchPlaces({
    int? lastId,
    required PlaceFilter filter,
  }) async {
    try {
      final params = {
        if (lastId != null) 'last_id': lastId,
        ...filter.toMap(),
      };
      final response = await _dio.get('/places/', queryParameters: params);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['results'];
        return data.map((json) => PlaceModel.fromJson(json)).toList();
      } else {
        throw Exception('Ошибка получения объявлений');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<PlaceDetailModel?> fetchPlaceDetail(int placeId) async {
    try {
      final response = await _dio.get('/places/$placeId/');

      // CustomResponse => { "results": { ...place... } }
      final data = response.data['results'] as Map<String, dynamic>;
      return PlaceDetailModel.fromJson(data);
    } catch (e) {
      print('Ошибка загрузки объявления: $e');
      rethrow;
    }
  }

    /// 🔹 Маркеры для карты по фильтру:
  /// - если есть placeIds -> берём только их
  /// - иначе фильтруем по categoryId / query
  Future<List<MapPlaceMarkerModel>> fetchPlacesForMapMarkers(
    MapPlaceFilter filter,
  ) async {
    // если совсем пустой фильтр без города — лучше сразу вернуть []
    if (filter.cityId == 0) return [];

    try {
      // базовые параметры
      final params = <String, dynamic>{
        'city_id': filter.cityId.toString(),
      };

      // 1) если передали конкретные id — используем только их
      if (filter.placeIds != null && filter.placeIds!.isNotEmpty) {
        params['ids'] = filter.placeIds!.join(',');
      } else {
        // 2) иначе можно фильтровать по категории / поиску
        if (filter.categoryId != null) {
          params['category_id'] = filter.categoryId.toString();
        }
        final q = filter.query?.trim();
        if (q != null && q.isNotEmpty) {
          params['q'] = q;
        }
      }

      final response = await _dio.get(
        '/places/map/markers/',
        queryParameters: params,
      );

      // ожидаем CustomResponse => { "results": [ {...}, {...} ] }
      final List<dynamic> data = response.data['results'];

      return data
          .map(
            (json) =>
                MapPlaceMarkerModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      print('Ошибка загрузки мест для карты: $e');
      rethrow;
    }
  }

  /// 🔹 Упрощённая деталка для компактной карточки на карте
  /// GET /places/map/detail-card/<id>/
  Future<MapPlaceCardModel?> fetchPlaceForMapCard(int placeId) async {
    try {
      final response = await _dio.get('/places/map/detail-card/$placeId/');

      // ожидаем CustomResponse => { "results": { ... } }
      final data = response.data['results'] as Map<String, dynamic>;
      return MapPlaceCardModel.fromJson(data);
    } catch (e) {
      print('Ошибка загрузки карточки места для карты: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> submitReview({
    required int placeId,
    required int rating,
    required String comment,
  }) async {
    try {
      final response = await _dio.post(
        'places/reviews/create/',
        data: {
          'rating': rating,
          'comment': comment,
          'place_id': placeId,
        },
        options: Options(extra: {"withAuth": true}),
      );

      // ожидаем: { "results": { review: {...}, average_rating: 4.3, total_reviews: 27 } }
      return response.data['results'];
    } catch (e) {
      throw Exception('Ошибка при отправке отзыва');
    }
  }
}
