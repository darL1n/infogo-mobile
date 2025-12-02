import 'package:flutter/material.dart';
import 'package:mobile/models/place.dart';
import 'package:mobile/models/place_detail.dart';
import 'package:mobile/models/place_filter.dart';
import 'package:mobile/providers/history_provider.dart';
import 'package:mobile/services/place_service.dart';
import 'package:provider/provider.dart';

class PlaceProvider extends ChangeNotifier {
  final PlaceService _placeService = PlaceService();
  List<PlaceModel> _places = [];
  final List<PlaceModel> _searchResults = [];
  final bool _isSearchLoading = false;
  PlaceDetailModel? _place;
  bool _isLoading = false;
  bool _isPlaceLoading = false;
  bool _hasMore = true;
  int? _lastId;
  PlaceFilter _filter = const PlaceFilter();



  PlaceFilter get filter => _filter;
  List<PlaceModel> get places => _places;
  bool get isLoading => _isLoading;
  bool get isPlaceLoading => _isPlaceLoading;
  List<PlaceModel> get searchResults => _searchResults;
  bool get isSearchLoading => _isSearchLoading;
  bool get hasMore => _hasMore;
  PlaceDetailModel? get place => _place;

  Future<void> fetchPlaces({
  PlaceFilter? filterOverride,
  bool refresh = false,
}) async {
  final filter = filterOverride ?? _filter;
  debugPrint("fetchPlaces");

  if (_isLoading) return;

  _isLoading = true;
  if (refresh) {
    _places = [];
    _lastId = null;
    _hasMore = true;
    notifyListeners();
  }

  try {
    final newPlaces = await _placeService.fetchPlaces(
      lastId: _lastId,
      filter: filter, // 👈 прокидываем весь фильтр
    );

    if (newPlaces.isEmpty) {
      _hasMore = false;
    } else {
      _places.addAll(newPlaces);
      _lastId = newPlaces.last.id;
    }
  } catch (e) {
    debugPrint('Ошибка загрузки объявлений: $e');
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}


  Future<void> fetchPlaceDetail(
    int id, {
    bool addToHistory = false,
    BuildContext? context,
  }) async {
    if (_isPlaceLoading) return;
    _isPlaceLoading = true;
    notifyListeners(); // Уведомляем UI о начале загрузки

    try {
      final placeDetail = await _placeService.fetchPlaceDetail(id);
      _place = placeDetail;
      if (addToHistory && context != null && placeDetail != null) {
        final historyProvider = context.read<HistoryProvider>();
        historyProvider.add(placeDetail.id);
      }
    } catch (e) {
      print('Ошибка загрузки подробностей места: $e');
      _place = null;
    } finally {
      _isPlaceLoading = false;
      Future.microtask(() => notifyListeners());
    }
  }

  Future<void> addReview({
    required int placeId,
    required int rating,
    required String comment,
  }) async {
    try {
      final result = await _placeService.submitReview(
        placeId: placeId,
        rating: rating,
        comment: comment,
      );

      final review = Review.fromJson(result['review']);
      _place?.reviews.insert(0, review);

      // Обновляем рейтинг и количество отзывов
      _place?.averageRating =
          (result['average_rating'] as num?)?.toDouble() ??
          _place!.averageRating;
      _place?.totalReviews = result['total_reviews'] ?? _place!.totalReviews;

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }



  void updateFilter(PlaceFilter newFilter) {
    _filter = newFilter;
    notifyListeners();
  }


  void clearPlaces() {
    _places = [];
    _lastId = null;
    _hasMore = true;
    _isLoading = false;
  }
}
