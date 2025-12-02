import 'package:flutter/material.dart';
import 'package:mobile/models/event.dart';
import 'package:mobile/services/event_service.dart';

class EventProvider extends ChangeNotifier {
  final EventService _service = EventService();

  List<EventModel> _events = [];
  bool _isLoading = false;
  String? _error;
  EventFilter _filter = const EventFilter();

  List<EventModel> _homeFeatured = [];
  bool _homeLoading = false;

  List<EventModel> get homeFeatured => _homeFeatured;
  bool get homeLoading => _homeLoading;

  List<EventModel> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;
  EventFilter get filter => _filter;

  /// Обновить фильтр (частично) и, опционально, сразу перезагрузить
  Future<void> updateFilter(
    EventFilter newFilter, {
    bool refresh = true,
  }) async {
    _filter = newFilter;
    if (refresh) {
      await fetchEvents();
    } else {
      notifyListeners();
    }
  }

  /// Задать дефолтный фильтр под город (можно вызывать из Home / Catalog)
  Future<void> initForCity(int? cityId) async {
    _filter = EventFilter.defaultForCity(cityId);
    await fetchEvents();
  }

  Future<void> fetchEvents() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.fetchEvents(
        cityId: _filter.cityId,
        placeId: _filter.placeId,
        categoryId: _filter.categoryId,
        isPublished: _filter.isPublished,
        isFeatured: _filter.isFeatured,
        isFree: _filter.isFree,
        query: _filter.query,
        dateFrom: _filter.dateFrom,
        dateTo: _filter.dateTo,
      );
      _events = result;
    } catch (e, st) {
      debugPrint('❌ Ошибка загрузки событий: $e\n$st');
      _error = 'Не удалось загрузить события';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadHomeFeatured(int cityId) async {
    if (_homeLoading) return;
    _homeLoading = true;
    notifyListeners();

    try {
      _homeFeatured = await _service.fetchFeaturedForHome(cityId);
    } finally {
      _homeLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await fetchEvents();
  }

  void clear() {
    _events = [];
    _error = null;
    notifyListeners();
  }
}
