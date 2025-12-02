// lib/services/news_service.dart
import 'package:dio/dio.dart';
import 'package:mobile/models/news.dart';
import 'api_client.dart';

class NewsService {
  final Dio _api = ApiClient.dio;

  Future<List<NewsModel>> fetchNews({
    int? cityId,
    bool? isPublished,
    bool? isFeatured,
    String? query,
  }) async {
    final params = <String, dynamic>{};

    if (cityId != null) params['city_id'] = cityId.toString();
    if (isPublished != null) {
      params['is_published'] = isPublished ? '1' : '0';
    }
    if (isFeatured != null) {
      params['is_featured'] = isFeatured ? '1' : '0';
    }
    if (query != null && query.trim().isNotEmpty) {
      params['q'] = query.trim();
    }

    final resp = await _api.get(
      'news/',
      queryParameters: params,
      options: Options(
        extra: {
          'withAuth': false, // новости публичные
        },
      ),
    );

    // CustomResponse -> {"results": [...]}
    final raw = resp.data['results'] as List<dynamic>;
    return raw
        .map((e) => NewsModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Для главной: последние 3 избранные новости по городу
  Future<List<NewsModel>> fetchFeaturedForHome(int cityId) async {
    final resp = await _api.get(
      'news/',
      queryParameters: {
        'city_id': cityId.toString(),
        'is_published': '1',
        'is_featured': '1',
        'limit': '3',
      },
      options: Options(
        extra: {
          'withAuth': false,
        },
      ),
    );

    final raw = resp.data['results'] as List<dynamic>;
    return raw
        .map((e) => NewsModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<NewsDetailModel> fetchDetail(int id) async {
    final resp = await _api.get(
      'news/$id/',
      options: Options(
        extra: {
          'withAuth': false,
        },
      ),
    );

    final raw = resp.data['results'] as Map<String, dynamic>;
    return NewsDetailModel.fromJson(raw);
  }
}
