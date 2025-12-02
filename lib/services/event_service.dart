import 'package:dio/dio.dart';
import 'package:mobile/models/event.dart';
import 'api_client.dart';

class EventService {
  final Dio _api = ApiClient.dio;

  Future<List<EventModel>> fetchEvents({
    int? cityId,
    int? placeId,
    int? categoryId,
    bool? isPublished,
    bool? isFeatured,
    bool? isFree,
    String? query,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final params = <String, dynamic>{};

    if (cityId != null) params['city_id'] = cityId.toString();
    if (placeId != null) params['place_id'] = placeId.toString();
    if (categoryId != null) params['category_id'] = categoryId.toString();
    if (isPublished != null) params['is_published'] = isPublished ? '1' : '0';
    if (isFeatured != null) params['is_featured'] = isFeatured ? '1' : '0';
    if (isFree != null) params['is_free'] = isFree ? '1' : '0';
    if (query != null && query.trim().isNotEmpty) {
      params['q'] = query.trim();
    }
    if (dateFrom != null) params['date_from'] = dateFrom.toIso8601String();
    if (dateTo != null) params['date_to'] = dateTo.toIso8601String();

    final response = await _api.get(
      'events/',
      queryParameters: params,
      options: Options(
        extra: {
          // Скорее всего события публичные, auth не нужен;
          // если нужно – поменяешь на true
          'withAuth': false,
        },
      ),
    );

    // CustomResponse → {"results": [...]}
    final raw = response.data['results'] as List<dynamic>;
    return raw
        .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<EventModel>> fetchFeaturedForHome(int cityId) async {
    final resp = await _api.get(
      'events/',
      queryParameters: {
        'city_id': cityId.toString(),
        'is_published': '1',
        'is_featured': '1',
        'limit': 3, // бэкенд может игнорить, но не мешает
      },
      options: Options(extra: {'withAuth': false}),
    );

    final raw = resp.data['results'] as List<dynamic>;
    final list = raw
        .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
        .toList();

    // На всякий случай ограничим 3 штуками и на клиенте
    if (list.length > 3) {
      return list.sublist(0, 3);
    }
    return list;
  }
}
