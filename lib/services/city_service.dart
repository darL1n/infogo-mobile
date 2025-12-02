import 'package:dio/dio.dart';
import 'package:mobile/models/city.dart';
import 'package:mobile/services/api_client.dart';

class CityService {
  final Dio _dio = ApiClient.dio;

  Future<List<CityModel>> fetchCities() async {
    try {
      final response = await _dio.get("locations/cities/");
      final body = response.data;

      print('🌍 /locations/cities/ response type: ${body.runtimeType}');
      // print('🌍 body: $body'); // можно временно раскомментировать, чтобы увидеть сырой ответ

      late final List<dynamic> rawList;

      if (body is List) {
        // Случай, если DRF отдаёт просто список без пагинации
        rawList = body;
      } else if (body is Map<String, dynamic>) {
        // Пагинация или CustomResponse
        final list = body['results'] ?? body['data'] ?? body['items'];
        if (list is List) {
          rawList = list;
        } else if (list == null) {
          rawList = const [];
        } else {
          throw Exception(
            'Ожидался список городов в results/data/items, а пришло: ${list.runtimeType}',
          );
        }
      } else {
        throw Exception('Неожиданный формат ответа: ${body.runtimeType}');
      }

      // Отбрасываем все null и всё, что не Map
      final citiesJson =
          rawList.whereType<Map<String, dynamic>>().toList(growable: false);

      return citiesJson.map((json) => CityModel.fromJson(json)).toList();
    } catch (e, st) {
      print('❌ Ошибка загрузки списка городов: $e\n$st');
      throw Exception("Ошибка загрузки списка городов");
    }
  }

  Future<CityModel> fetchCityByCoords({
    required double lat,
    required double lng,
  }) async {
    try {
      final response = await _dio.get(
        "locations/cities/by-coords/",
        queryParameters: {
          'lat': lat,
          'lng': lng,
        },
      );

      return CityModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      print(e);
      throw Exception("Не удалось определить город по координатам");
    }
  }
}
