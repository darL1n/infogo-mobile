import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mobile/models/city.dart';
import 'package:mobile/services/city_service.dart';
import 'package:mobile/services/location_service.dart';
import 'package:mobile/storages/hive_storage.dart';

class CityProvider extends ChangeNotifier {
  CityProvider({
    CityService? cityService,
    LocationService? locationService,
  })  : _cityService = cityService ?? CityService(),
        _locationService = locationService ?? LocationService();

  final CityService _cityService;
  final LocationService _locationService;

  List<CityModel> _cities = [];
  bool _isLoaded = false;

  CityModel? _currentCity;
  int? _currentCityId;

  bool _isDetectingLocation = false;
  String? _lastLocationError;

  // ===== публичные геттеры =====

  List<CityModel> get cities => _cities;
  bool get isEmpty => _cities.isEmpty;
  bool get isLoaded => _isLoaded;

  CityModel? get currentCity {
    if (_currentCity != null) return _currentCity;
    if (_currentCityId == null) return null;
    return getCityById(_currentCityId!);
  }

  int? get currentCityId => _currentCityId;

  bool get isDetectingLocation => _isDetectingLocation;
  String? get lastLocationError => _lastLocationError;

  // ===== загрузка городов =====

  Future<void> loadCities({bool forceNetwork = false}) async {
  debugPrint('🔄 loadCities вызван (forceNetwork=$forceNetwork)');

  // если уже загружено в RAM и не просим форс — выходим
  if (!forceNetwork && _isLoaded && _cities.isNotEmpty) return;

  // 1) пробуем из Hive, если НЕ форс
  if (!forceNetwork) {
    _cities = HiveStorage.getCities();
    _currentCityId = HiveStorage.getCurrentCityId();

    if (_cities.isNotEmpty) {
      _isLoaded = true;

      if (_currentCityId != null) {
        _currentCity = getCityById(_currentCityId!);
      }

      // тут можно ПАРАЛЛЕЛЬНО в фоне дернуть обновление с сервера, если хочешь
      Future.microtask(notifyListeners);
      return;
    }
  }

  // 2) иначе/помимо — грузим с API
  try {
    final citiesFromApi = await _cityService.fetchCities();
    _cities = citiesFromApi;
    _isLoaded = true;

    await HiveStorage.saveCities(citiesFromApi);

    _currentCityId = HiveStorage.getCurrentCityId();
    if (_currentCityId != null) {
      _currentCity = getCityById(_currentCityId!);
    }

    notifyListeners();
  } catch (e, st) {
    debugPrint("❌ Ошибка загрузки городов: $e\n$st");
    _isLoaded = false;
    _lastLocationError = 'Ошибка загрузки списка городов';
    notifyListeners();
  }
}


  /// Определяем город по геолокации.
  /// Сейчас вариант с Haversine по локальному списку.
  Future<void> detectCityByLocation({bool checkCurrent = false}) async {
    _lastLocationError = null;

    if (checkCurrent && _currentCityId != null) {
      return;
    }

    // подстрахуемся, что города вообще есть
    if (_cities.isEmpty && !_isLoaded) {
      await loadCities();
    }

    if (_cities.isEmpty) {
      _lastLocationError = 'Не удалось загрузить список городов.';
      notifyListeners();
      return;
    }

    _isDetectingLocation = true;
    notifyListeners();

    try {
      // ⬇️ тут теперь используем LocationService, а не CityService
      final position = await _locationService.getCurrentPosition();

      double minDistance = double.infinity;
      CityModel? nearest;

      for (var city in _cities) {
        final distance = _haversine(
          position.latitude,
          position.longitude,
          city.latitude,
          city.longitude,
        );
        if (distance < minDistance) {
          minDistance = distance;
          nearest = city;
        }
      }

      if (nearest == null) {
        _lastLocationError =
            'Вашу локацию не удалось сопоставить ни с одним городом.';
        notifyListeners();
        return;
      }

      setCurrentCity(nearest.id);
      debugPrint("📍 Ближайший город: ${nearest.name}");
    } on LocationPermissionException catch (e) {
      // понятная ошибка про разрешения
      _lastLocationError = e.message;
      notifyListeners();
    } on LocationServiceException catch (e) {
      // служба геолокации выключена и т.п.
      _lastLocationError = e.message;
      notifyListeners();
    } catch (e) {
      _lastLocationError = 'Неизвестная ошибка геолокации: $e';
      notifyListeners();
    } finally {
      _isDetectingLocation = false;
      notifyListeners();
    }
  }

  // ===== выбор города вручную =====

  void setCurrentCity(int cityId) {
    _currentCityId = cityId;
    _currentCity = getCityById(cityId);
    HiveStorage.saveCurrentCityId(cityId);
    notifyListeners();
  }

  CityModel? getCityById(int id) {
    try {
      return _cities.firstWhere((city) => city.id == id);
    } catch (_) {
      return null;
    }
  }

  // ===== математика для расстояния =====

  double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // км
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180);
}
