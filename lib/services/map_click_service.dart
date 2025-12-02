import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';

import 'package:mobile/models/map_click.dart';
import 'package:mobile/services/api_client.dart'; // где у тебя baseUrl

class MapClickService {
  final Dio _dio = ApiClient.dio;

  Future<MapClickResult> fetchPlacesByPoint({
    required double lat,
    required double lng,
    double radiusM = 60,
    int? cityId,
  }) async {
    final query = <String, dynamic>{
      'lat': lat,
      'lng': lng,
      'radius_m': radiusM,
    };
    if (cityId != null) {
      query['city_id'] = cityId;
    }

    final response = await _dio.get(
      '/places/map/places-by-point/',
      queryParameters: query,
    );
    print(response.data);

    return MapClickResult.fromJson(response.data['results'] as Map<String, dynamic>);
  }
}
