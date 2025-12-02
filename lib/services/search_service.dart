import 'package:dio/dio.dart';
import 'package:mobile/services/api_client.dart';

class SearchService {
  final Dio _dio = ApiClient.dio;

  /// Запрос подсказок поиска
  ///
  /// Бэк отдаёт CustomResponse:
  /// { "results": { query, history, popular, suggestions, categories } }
  Future<Map<String, dynamic>> fetchSuggestions(
    String query, {
    int? cityId,
    CancelToken? cancelToken,
  }) async {
    final params = <String, dynamic>{'query': query};
    if (cityId != null) {
      params['city_id'] = cityId;
    }

    final response = await _dio.get(
      'search/suggestions/',
      queryParameters: params,
      cancelToken: cancelToken,
    );

    final results = response.data['results'];
    if (results is Map<String, dynamic>) {
      return results;
    }
    return Map<String, dynamic>.from(results as Map);
  }

   /// Логируем факт выполненного поиска
  Future<void> logSearch({
    required String query,
    int? cityId,
    String? source,
  }) async {
    try {
      await _dio.post(
        'search/log/',
        data: {
          'query': query,
          if (cityId != null) 'city_id': cityId,
          if (source != null) 'source': source,
        },
      );
    } catch (e) {
      // логирование — не критично, поэтому без проброса
      // debugPrint('logSearch error: $e');
    }
  }
}
