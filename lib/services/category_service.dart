import 'package:dio/dio.dart';
import 'package:mobile/models/category.dart';
import 'package:mobile/utils/category.dart';
import 'api_client.dart';

class CategoryService {
  final Dio _dio = ApiClient.dio;

  Future<List<CategoryModel>> fetchCategoryTree({
    required int cityId,
  }) async {
    try {
      final response = await _dio.get(
        'places/categories/',
        queryParameters: {
          'city_id': cityId,
        },
      );

      final body = response.data;
      late final List<dynamic> rawList;

      if (body is List) {
        rawList = body;
      } else if (body is Map<String, dynamic>) {
        final list = body['results'] ?? body['data'] ?? body['items'];
        if (list is List) {
          rawList = list;
        } else if (list == null) {
          rawList = const [];
        } else {
          throw Exception(
            'Ожидался список категорий в results/data/items, а пришло: ${list.runtimeType}',
          );
        }
      } else {
        throw Exception('Неожиданный формат ответа для категорий: ${body.runtimeType}');
      }

      final flatCategories =
          rawList.whereType<Map<String, dynamic>>().map((json) {
        return CategoryModel.fromJson(json);
      }).toList();

      final treeCategories = buildCategoryTree(flatCategories);
      return treeCategories;
    } catch (e, st) {
      print('❌ Ошибка получения категорий: $e\n$st');
      throw Exception('Ошибка получения категорий');
    }
  }
}
