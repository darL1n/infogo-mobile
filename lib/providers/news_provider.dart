// lib/providers/news_provider.dart
import 'package:flutter/material.dart';
import 'package:mobile/models/news.dart';
import 'package:mobile/services/news_service.dart';

class NewsProvider extends ChangeNotifier {
  final NewsService _service = NewsService();

  List<NewsModel> _news = [];
  bool _isLoading = false;
  String? _error;
  NewsFilter _filter = const NewsFilter();

  List<NewsModel> _homeNews = [];
  bool _homeLoading = false;

  List<NewsModel> get news => _news;
  bool get isLoading => _isLoading;
  String? get error => _error;
  NewsFilter get filter => _filter;

  List<NewsModel> get homeNews => _homeNews;
  bool get homeLoading => _homeLoading;

  /// дефолтный фильтр под город и загрузка ленты для экрана "Все новости"
  Future<void> initForCity(int? cityId) async {
    _filter = NewsFilter.defaultForCity(cityId);
    await fetchNews();
  }

  Future<void> fetchNews() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.fetchNews(
        cityId: _filter.cityId,
        isPublished: _filter.isPublished,
        isFeatured: _filter.isFeatured,
        query: _filter.query,
      );
      _news = result;
    } catch (e, st) {
      debugPrint('❌ Ошибка загрузки новостей: $e\n$st');
      _error = 'Не удалось загрузить новости';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<NewsDetailModel> fetchDetail(int id) async {
    // просто прокинуть в сервис и вернуть результат,
    // без notifyListeners (чтобы не ловить setState during build)
    return _service.fetchDetail(id);
  }

  Future<void> refresh() async {
    await fetchNews();
  }

  /// Для главной: 3 избранные новости
  Future<void> loadHomeFeatured(int cityId) async {
    if (_homeLoading) return;

    _homeLoading = true;
    notifyListeners();

    try {
      _homeNews = await _service.fetchFeaturedForHome(cityId);
    } catch (e, st) {
      debugPrint('⚠️ Ошибка загрузки новостей для главной: $e\n$st');
      // без error — просто не покажем блок
    } finally {
      _homeLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _news = [];
    _error = null;
    notifyListeners();
  }

  Future<void> updateFilter(NewsFilter newFilter,
      {bool refresh = true}) async {
    _filter = newFilter;
    if (refresh) {
      await fetchNews();
    } else {
      notifyListeners();
    }
  }
}

class NewsFilter {
  final int? cityId;
  final bool? isPublished;
  final bool? isFeatured;
  final String? query;

  const NewsFilter({
    this.cityId,
    this.isPublished,
    this.isFeatured,
    this.query,
  });

  factory NewsFilter.defaultForCity(int? cityId) => NewsFilter(
        cityId: cityId,
        isPublished: true,
      );

  NewsFilter copyWith({
    int? cityId,
    bool? isPublished,
    bool? isFeatured,
    String? query,
  }) {
    return NewsFilter(
      cityId: cityId ?? this.cityId,
      isPublished: isPublished ?? this.isPublished,
      isFeatured: isFeatured ?? this.isFeatured,
      query: query ?? this.query,
    );
  }
}
