import 'package:flutter/material.dart';
import 'package:mobile/models/favorite_place.dart';
import 'package:mobile/providers/user_provider.dart';
import 'package:mobile/services/favorite_service.dart';

class FavoriteProvider extends ChangeNotifier {
  final FavoriteService _service = FavoriteService();

  // Используем Map для хранения избранных мест, где ключ – place.id
  final Map<int, FavoritePlaceModel> _favorites = {};
  bool _isLoaded = false;

  List<FavoritePlaceModel> get favorites => _favorites.values.toList();
  List<int> get ids => _favorites.keys.toList();
  bool get isEmpty => _favorites.isEmpty;

  bool isFavorite(int placeId) => _favorites.containsKey(placeId);

  FavoritePlaceModel? getByPlaceId(int placeId) => _favorites[placeId];

  Future<void> load(UserProvider userProvider) async {
    if (_isLoaded) return;

    debugPrint('⭐ FavoriteProvider.load start (isAuth=${userProvider.isAuthenticated})');

    try {
      List<FavoritePlaceModel> fetchedFavorites = [];

      if (userProvider.isAuthenticated) {
        debugPrint('⭐ load: syncLocalToServer...');
        fetchedFavorites = await _service.syncLocalToServer();
        debugPrint('⭐ syncLocalToServer -> ${fetchedFavorites.length}');

        if (fetchedFavorites.isEmpty) {
          debugPrint('⭐ load: fetchFavoritesFromServer...');
          fetchedFavorites = await _service.fetchFavoritesFromServer();
          debugPrint('⭐ fetchFavoritesFromServer -> ${fetchedFavorites.length}');
        }
      } else {
        final localIds = _service.getLocalFavorites();
        debugPrint('⭐ load: guest, localIds = $localIds');

        if (localIds.isNotEmpty) {
          final places = await _service.fetchByIds(localIds);
          debugPrint('⭐ fetchByIds -> ${places.length}');

          fetchedFavorites = places
              .map(
                (place) => FavoritePlaceModel(
                  id: -1,
                  addedAt: DateTime.now(),
                  place: place,
                ),
              )
              .toList();
        } else {
          debugPrint('⭐ load: no local favorites, skip fetchByIds');
        }
      }

      _favorites
        ..clear()
        ..addEntries(
          fetchedFavorites.map((fav) => MapEntry(fav.place.id, fav)),
        );

      _isLoaded = true;
      debugPrint('⭐ FavoriteProvider.load done, favorites=${_favorites.length}');
      notifyListeners();
    } catch (e, st) {
      debugPrint('❌ FavoriteProvider.load error: $e\n$st');
      // чтобы init не падал бесконечно — выставим как загруженный, пусть будет пусто
      _isLoaded = true;
    }
  }

  Future<void> toggle(int placeId, UserProvider userProvider) async {
    final isNowFavorite = !_favorites.containsKey(placeId);

    if (isNowFavorite) {
      if (userProvider.isAuthenticated) {
        await _service.addToServer(placeId);
      } else {
        _service.addToLocal(placeId);
      }
      // Получаем объект для UI
      final places = await _service.fetchByIds([placeId]);
      if (places.isNotEmpty) {
        _favorites[placeId] = FavoritePlaceModel(
          id: -1,
          addedAt: DateTime.now(),
          place: places.first,
        );
      }
    } else {
      if (userProvider.isAuthenticated) {
        await _service.removeFromServer(placeId);
      } else {
        _service.removeFromLocal(placeId);
      }
      _favorites.remove(placeId);
    }

    notifyListeners();
  }

  Future<void> remove(int placeId, UserProvider userProvider) async {
    if (_favorites.containsKey(placeId)) {
      await toggle(placeId, userProvider);
    }
  }

  Future<void> clear() async {
    _favorites.clear();
    _isLoaded = false;
    notifyListeners();
  }
}
