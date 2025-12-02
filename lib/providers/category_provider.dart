import 'package:flutter/material.dart';
import 'package:mobile/models/category.dart';
import 'package:mobile/services/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _error;

  /// для какого города сейчас загружены категории
  int? _loadedCityId;
  bool _isLoaded = false;

  final Map<int, CategoryModel> _categoryCache = {};
  final Set<int> _redirectedCategoryIds = {};

  // ===== публичные геттеры =====

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoaded => _isLoaded;
  int? get loadedCityId => _loadedCityId;

  bool hasRedirected(int categoryId) =>
      _redirectedCategoryIds.contains(categoryId);
  void markAsRedirected(int categoryId) =>
      _redirectedCategoryIds.add(categoryId);

  /// Загружаем категории для конкретного города
  Future<void> fetchCategoriesForCity(
    int cityId, {
    bool force = false,
  }) async {
    // если уже загружены для этого города и не просили принудительно — выходим
    if (!force && _isLoaded && _loadedCityId == cityId) return;
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result =
          await _categoryService.fetchCategoryTree(cityId: cityId);

      _categories = result;
      _loadedCityId = cityId;
      _isLoaded = true;

      _categoryCache.clear();
      _cacheCategories(_categories);
    } catch (e) {
      _error = 'Ошибка загрузки категорий';
      _isLoaded = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Сбрасываем категории (например, если город стал null)
  void clear() {
    _categories = [];
    _categoryCache.clear();
    _loadedCityId = null;
    _isLoaded = false;
    _error = null;
    _redirectedCategoryIds.clear();
    notifyListeners();
  }

  // ===== вспомогательные методы =====

  CategoryModel? findCategoryById(int id) => _categoryCache[id];

  void _cacheCategories(List<CategoryModel> categories) {
    for (final category in categories) {
      _categoryCache[category.id] = category;
      _cacheCategories(category.children);
    }
  }

  List<CategoryModel> getPathTo(int id) {
    final path = <CategoryModel>[];
    CategoryModel? current = _categoryCache[id];
    while (current != null) {
      path.insert(0, current);
      current = _categoryCache[current.parentId ?? -1];
    }
    return path;
  }

  bool isLeafCategory(int categoryId) {
    final category = findCategoryById(categoryId);
    return category != null && category.children.isEmpty;
  }
}
