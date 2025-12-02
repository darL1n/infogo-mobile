import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobile/models/category.dart';
import 'package:mobile/services/search_service.dart';

class SearchProvider extends ChangeNotifier {
  final SearchService _searchService = SearchService();

  String _currentQuery = '';
  bool _isLoading = false;

  // 🔹 Подсказки с бэка
  List<String> serverHistory = [];       // недавние запросы пользователя
  List<String> popularSuggestions = [];  // популярные запросы по городу
  List<String> placeSuggestions = [];    // названия мест
  List<CategoryModel> categorySuggestions = []; // категории

  CancelToken? _cancelToken;

  String get currentQuery => _currentQuery;
  bool get isLoading => _isLoading;

  /// Основной метод: грузим подсказки по query + cityId
  Future<void> loadSuggestions(
    String query, {
    int? cityId,
  }) async {
    _currentQuery = query;

    // отменяем прошлый запрос
    _cancelToken?.cancel("new request");
    _cancelToken = CancelToken();

    _isLoading = true;
    serverHistory = [];
    popularSuggestions = [];
    placeSuggestions = [];
    categorySuggestions = [];
    notifyListeners();

    try {
      final data = await _searchService.fetchSuggestions(
        query,
        cityId: cityId,
        cancelToken: _cancelToken,
      );

      // ожидаем структуру:
      // {
      //   "query": "кофе",
      //   "history": [...],
      //   "popular": [...],
      //   "suggestions": [...],
      //   "categories": [...]
      // }

      serverHistory =
          List<String>.from((data['history'] ?? const []) as List);

      popularSuggestions =
          List<String>.from((data['popular'] ?? const []) as List);

      placeSuggestions =
          List<String>.from((data['suggestions'] ?? const []) as List);

      categorySuggestions =
          (data['categories'] as List)
              .map((json) => CategoryModel.fromJson(json))
              .toList();
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        debugPrint('SearchProvider.loadSuggestions: canceled');
      } else {
        debugPrint('SearchProvider.loadSuggestions error: $e');
      }
    } catch (e) {
      debugPrint('SearchProvider.loadSuggestions error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logSearch({
    required String query,
    int? cityId,
    String? source,
  }) async {
    await _searchService.logSearch(
      query: query,
      cityId: cityId,
      source: source,
    );
  }

  /// Очистить состояние при:
  /// - пустой query
  /// - уходе со страницы
  void clear() {
    _cancelToken?.cancel("clear");
    _isLoading = false;
    _currentQuery = '';

    serverHistory = [];
    popularSuggestions = [];
    placeSuggestions = [];
    categorySuggestions = [];
    notifyListeners();
  }
}
