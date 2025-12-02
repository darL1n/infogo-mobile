import 'package:flutter/material.dart';
import 'package:mobile/models/history_view_place.dart';
import 'package:mobile/providers/user_provider.dart';
import 'package:mobile/services/history_service.dart';

class HistoryProvider extends ChangeNotifier {
  final HistoryService _service = HistoryService();

  final Map<int, HistroyViewPlaceModel> _history = {};
  bool _isLoaded = false;
  bool _isLoading  = false;

  List<HistroyViewPlaceModel> get history => _history.values.toList();
  bool get isEmpty => _history.isEmpty;
  bool get isLoading => _isLoading;

  Future<void> load(UserProvider userProvider) async {
    if (_isLoaded) return;

    _isLoading = true;
    notifyListeners();

    List<HistroyViewPlaceModel> fetchedHistory;
    if (userProvider.isAuthenticated) {
      fetchedHistory = await _service.syncLocalToServer();
      fetchedHistory = await _service.fetchHistoryFromServer();
      // if (fetchedHistory.isEmpty) {
      //   fetchedHistory = await _service.fetchHistoryFromServer();
      // }
    } else {
      final localIds = _service.getLocalHistoryIds();
      final places = await _service.fetchByIds(localIds);
      fetchedHistory = places.map(
        (place) => HistroyViewPlaceModel(
          id: -1,
          viewedAt: DateTime.now(),
          place: place,
        ),
      ).toList();
    }

    _history
      ..clear()
      ..addEntries(fetchedHistory.map((history) => MapEntry(history.place.id, history)));

    _isLoaded = true;
    _isLoading = false;
    notifyListeners();

  }

  Future<void> add(int placeId) async {
    _service.addToLocal(placeId);
    _isLoaded = false; // чтобы при следующем `load()` обновить

    notifyListeners();
  }

  Future<void> clear() async {
    _service.clearLocal();
    _history.clear();
    _isLoaded = false;
    notifyListeners();
  }
}
