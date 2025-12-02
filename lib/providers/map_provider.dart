import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/models/map_place.dart';

import 'package:mobile/models/map_place_marker.dart';
import 'package:mobile/models/map_place_card.dart';
import 'package:mobile/models/place_marker.dart'; // если больше не нужен — можно удалить
import 'package:mobile/services/place_service.dart';
import 'package:mobile/services/navigation_service.dart';
import 'package:mobile/services/location_service.dart';

// 🔽 модели и сервис клика по карте
import 'package:mobile/services/map_click_service.dart';
import 'package:mobile/models/map_click.dart';

class MapProvider extends ChangeNotifier {
  MapProvider({
    PlaceService? placeService,
    LocationService? locationService,
    MapClickService? mapClickService,
  }) : _placeService = placeService ?? PlaceService(),
       _locationService = locationService ?? LocationService(),
       _mapClickService = mapClickService ?? MapClickService();

  final PlaceService _placeService;
  final LocationService _locationService;
  final MapClickService _mapClickService;

  // flutter_map controller
  MapController? mapController;

  // места и отрисовка
  List<MapPlaceMarkerModel> _places = []; // 🔹 только данные для маркеров
  List<Marker> _markers = [];
  List<Polyline> _polylines = [];

  // подсветка места (карточка)
  int? _highlightedPlaceId;
  MapPlaceCardModel? _highlightedPlace;

  // состояние карты
  bool _isMapReady = false;
  int? _pendingHighlightPlaceId;
  bool _openedWithHighlight = false;

  String _categoryFilterId = 'all';
  String get categoryFilterId => _categoryFilterId;

  void setCategoryFilter(String id) {
    if (_categoryFilterId == id) return;
    _categoryFilterId = id;
    _rebuildMarkers(); // перерисуем маркеры с учётом фильтра
    notifyListeners();
  }

  List<MapPlaceMarkerModel> get placesForList {
    return _applyCategoryFilter(_places);
  }

  List<MapPlaceMarkerModel> _applyCategoryFilter(
    List<MapPlaceMarkerModel> input,
  ) {
    switch (_categoryFilterId) {
      case 'rating':
        // сортируем по рейтингу
        final sorted = [...input];
        sorted.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        return sorted;

      case 'open':
        return input.where((p) => p.isOpenNow == true).toList();

      case 'events':
        return input.where((p) => p.hasUpcomingEvents == true).toList();

      case 'all':
      default:
        return input;
    }
  }

  // кэш карточек (detail-card) по id
  final Map<int, MapPlaceCardModel> _placeCache = {};

  // геолокация пользователя
  LatLng? _userLocation;
  bool _isLocating = false;

  // === стейт тапа по карте ===
  bool _isTapLoading = false;
  String? _tapError;
  MapClickResult? _tapResult;

  // ===== геттеры =====

  List<Marker> get markers => _markers;
  List<Polyline> get polylines => _polylines;

  bool _openedAsCategory = false;
  bool get openedAsCategory => _openedAsCategory;

  bool get isMapReady => _isMapReady;

  int? get highlightedPlaceId => _highlightedPlaceId;
  MapPlaceCardModel? get highlightedPlace => _highlightedPlace;

  LatLng? get userLocation => _userLocation;
  bool get isLocating => _isLocating;

  LatLngBounds? _cityBounds;
  LatLngBounds? get cityBounds => _cityBounds;

  LatLngBounds? get placesBounds => _buildPlacesBounds();

  bool get openedWithHighlight => _openedWithHighlight;

  // тапы по карте
  bool get isTapLoading => _isTapLoading;
  String? get tapError => _tapError;
  MapClickResult? get tapResult => _tapResult;

  MarkerViewModel? get highlightedMarker {
    if (_highlightedPlace == null ||
        _highlightedPlace!.latitude == null ||
        _highlightedPlace!.longitude == null) {
      return null;
    }
    return MarkerViewModel(
      id: _highlightedPlace!.id,
      latitude: _highlightedPlace!.latitude!,
      longitude: _highlightedPlace!.longitude!,
    );
  }

  // ===== инициализация: режим "список маркеров" =====
  //
  // Открыли карту из списка/категории:
  // нам нужен только набор маркеров по placeIds.
  //
  Future<void> initWithFilter(MapPlaceFilter filter) async {
    debugPrint(
      '[MapProvider] initWithFilter: city=${filter.cityId}, '
      'category=${filter.categoryId}, ids=${filter.placeIds?.length}',
    );

    _places = [];
    _markers = [];
    _polylines = [];
    _highlightedPlaceId = null;
    _highlightedPlace = null;

    _pendingHighlightPlaceId = null;
    _openedWithHighlight = false;

    _isTapLoading = false;
    _tapError = null;
    _tapResult = null;

    // 🔹 если есть categoryId и нет явного списка ids → режим категории
    _openedAsCategory =
        filter.categoryId != null &&
        (filter.placeIds == null || filter.placeIds!.isEmpty);

    try {
      _places = await _placeService.fetchPlacesForMapMarkers(filter);
    } catch (e) {
      debugPrint('initWithFilter: ошибка загрузки маркеров: $e');
      _places = [];
    }

    _rebuildMarkers();
    notifyListeners();

    // 👇 ЕДИНАЯ логика: если мы уже на готовой карте и в режиме категории —
    // сразу подгоняем камеру под маркеры (или границы города).
    if (_openedAsCategory && _isMapReady) {
      centerCategoryWithSheetBias(fallbackBounds: _cityBounds);
    }
  }

  /// 🔹 Режим "просто карта" — без мест, только геолокация/тапы
  void initPlain() {
    _places = [];
    _highlightedPlaceId = null;
    _highlightedPlace = null;
    _polylines = [];

    // сбрасываем состояние тапа
    _isTapLoading = false;
    _tapError = null;
    _tapResult = null;

    _openedAsCategory = false; // 🔹

    // важный момент: НЕ трогаем _userLocation
    // чтобы маркер пользователя мог остаться, если он уже был
    _rebuildMarkers(); // это уберёт маркеры мест, но оставит userLocation
    notifyListeners();
  }

  // ===== инициализация: режим "Показать на карте" (один placeId) =====
  //
  // Открыли карту из place_detail_screen: карточка + маркер.
  //
  Future<void> initForHighlight(int placeId) async {
    debugPrint(
      '[MapProvider] initForHighlight: placeId=$placeId, '
      'wasHighlighted=$_highlightedPlaceId',
    );

    _places = [];
    _markers = [];
    _polylines = [];
    _highlightedPlaceId = null;
    _highlightedPlace = null;

    _pendingHighlightPlaceId = placeId;
    _openedWithHighlight = true;

    _openedAsCategory = false; // 🔹

    // сбрасываем стейт тапа
    _isTapLoading = false;
    _tapError = null;
    _tapResult = null;

    _rebuildMarkers();
    notifyListeners();

    // если карта уже успела стать готовой — сразу подсветим
    if (_isMapReady && _pendingHighlightPlaceId != null) {
      final id = _pendingHighlightPlaceId!;
      _pendingHighlightPlaceId = null;
      await highlightPlace(id);
    }
  }

  // ===== события карты =====

  void onMapReady({LatLngBounds? cityBounds}) {
    _isMapReady = true;
    _cityBounds = cityBounds; // 👈 запомнили
    debugPrint(
      '[MapProvider] onMapReady isMapReady=$_isMapReady '
      'pending=$_pendingHighlightPlaceId openedAsCategory=$_openedAsCategory',
    );
    notifyListeners();

    // 1️⃣ если ждали placeId — подсветили и не трогаем категорийную логику
    if (_pendingHighlightPlaceId != null) {
      final id = _pendingHighlightPlaceId!;
      _pendingHighlightPlaceId = null;

      debugPrint('[MapProvider] onMapReady → highlightPlace($id)');
      highlightPlace(id);
      _requestUserLocation(centerOnMap: false);
      return;
    }

    // 2️⃣ режим "категория" — теперь тоже через bias-центрирование
    if (_openedAsCategory) {
      centerCategoryWithSheetBias(fallbackBounds: _cityBounds);

      // Ставим маркер юзера, но не двигаем камеру к нему
      _requestUserLocation(centerOnMap: false);
      return;
    }

    // 3️⃣ обычное открытие карты — центрируемся по пользователю
    _requestUserLocation(centerOnMap: true);
  }

  void clearHighlight() {
    _highlightedPlace = null;
    _highlightedPlaceId = null;
    _polylines.clear();

    _rebuildMarkers();
    notifyListeners();
  }

  void resetMap({bool notify = false}) {
    _places = [];
    _markers = [];
    _polylines = [];
    _highlightedPlaceId = null;
    _highlightedPlace = null;
    _isMapReady = false;
    _pendingHighlightPlaceId = null;
    _placeCache.clear();

    _userLocation = null;
    _isLocating = false;
    _openedWithHighlight = false;
    _openedAsCategory = false; // 🔹

    // сбрасываем стейт тапа
    _isTapLoading = false;
    _tapError = null;
    _tapResult = null;

    if (notify) {
      notifyListeners();
    }
  }

  // ===== bounds по текущим местам =====

  LatLngBounds? _buildPlacesBounds() {
    // берём уже отфильтрованные места (чтобы учесть фильтр чипов)
    final places = _applyCategoryFilter(_places);
    if (places.isEmpty) return null;

    double? minLat, maxLat, minLng, maxLng;

    for (final p in places) {
      final lat = p.latitude;
      final lng = p.longitude;
      if (lat == null || lng == null) continue;

      minLat = (minLat == null || lat < minLat) ? lat : minLat;
      maxLat = (maxLat == null || lat > maxLat) ? lat : maxLat;
      minLng = (minLng == null || lng < minLng) ? lng : minLng;
      maxLng = (maxLng == null || lng > maxLng) ? lng : maxLng;
    }

    if (minLat == null || maxLat == null || minLng == null || maxLng == null) {
      return null;
    }

    // если одно место — чуть расширим, чтобы fit не тупил
    if (minLat == maxLat) {
      minLat -= 0.001;
      maxLat += 0.001;
    }
    if (minLng == maxLng) {
      minLng -= 0.001;
      maxLng += 0.001;
    }

    final northWest = LatLng(maxLat, minLng); // северо-запад
    final southEast = LatLng(minLat, maxLng); // юго-восток

    return LatLngBounds(northWest, southEast);
  }

  /// Центрирование карты по местам категории с учётом нижней шторки.
  void centerCategoryWithSheetBias({
    LatLngBounds? fallbackBounds,
    double verticalBias = 0.15, // 15% вверх от геометрического центра
    double defaultZoom = 13.0,
  }) {
    if (!_isMapReady || mapController == null) return;

    final bounds = _buildPlacesBounds() ?? fallbackBounds;
    if (bounds == null) return;

    final north = bounds.northWest.latitude;
    final south = bounds.southEast.latitude;
    final west = bounds.northWest.longitude;
    final east = bounds.southEast.longitude;

    // 0.5 — середина, +bias — поднимаем немного вверх
    final centerLat = south + (north - south) * (0.5 + verticalBias);
    final centerLng = west + (east - west) * 0.5;
    final center = LatLng(centerLat, centerLng);

    final controller = mapController!;
    final zoom = defaultZoom;

    debugPrint(
      '[MapProvider] centerCategoryWithSheetBias '
      'center=$center zoom=$zoom (bounds=$north,$west → $south,$east)',
    );

    controller.move(center, zoom);
  }

  // ===== выбор / подсветка места =====

  Future<void> _selectPlace(int placeId) async {
    debugPrint(
      '[MapProvider] _selectPlace start '
      'id=$placeId isMapReady=$_isMapReady controllerNull=${mapController == null}',
    );

    _highlightedPlaceId = placeId;
    final controller = mapController;

    try {
      if (_placeCache.containsKey(placeId)) {
        _highlightedPlace = _placeCache[placeId];
        debugPrint(
          '[MapProvider] _selectPlace from cache: '
          'lat=${_highlightedPlace?.latitude}, lng=${_highlightedPlace?.longitude}',
        );
      } else {
        final card = await _placeService.fetchPlaceForMapCard(placeId);
        _highlightedPlace = card;
        debugPrint(
          '[MapProvider] _selectPlace loaded from API: '
          'lat=${_highlightedPlace?.latitude}, lng=${_highlightedPlace?.longitude}',
        );
        if (card != null) {
          _placeCache[placeId] = card;
        }
      }
    } catch (e) {
      debugPrint('Ошибка при загрузке detail-card для места $placeId: $e');
      return;
    }

    _polylines.clear();

    _rebuildMarkers();

    // 🔥 как только есть карточка и, возможно, userLocation — считаем
    _updateHighlightedDistance();

    notifyListeners();

    final marker = highlightedMarker;
    debugPrint(
      '[MapProvider] before camera.move '
      'marker=$marker isMapReady=$_isMapReady controllerNull=${controller == null}',
    );

    if (marker != null && _isMapReady && controller != null) {
      await Future.delayed(const Duration(milliseconds: 200));
      controller.move(LatLng(marker.latitude, marker.longitude), 15);
      debugPrint('[MapProvider] camera.move done');
    } else {
      debugPrint('[MapProvider] camera.move SKIPPED');
    }
  }

  Future<void> highlightPlace(int placeId) async {
    await _selectPlace(placeId);
  }

  Future<void> onMarkerTap(int placeId) async {
    await _selectPlace(placeId);
  }

  Future<void> openLocationSettings() {
    return _locationService.openSystemLocationSettings();
  }

  Future<void> openAppSettings() {
    return _locationService.openAppSettings();
  }

  // ===== открытие маршрута =====

  Future<void> buildRouteToHighlighted(BuildContext context) async {
    final marker = highlightedMarker;
    if (marker == null) return;

    try {
      await NavigationService.openRoute(
        latitude: marker.latitude,
        longitude: marker.longitude,
        label: _highlightedPlace?.name,
        context: context, // 👈 даём контекст для bottom sheet
      );
    } catch (e) {
      debugPrint('Ошибка открытия маршрута: $e');

      // чуть более дружелюбно чем просто лог
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Не удалось открыть маршрут. '
            'Проверьте, установлено ли картографическое приложение.',
          ),
        ),
      );
    }
  }

  // ===== "Моё местоположение" =====

  Future<String?> _requestUserLocation({required bool centerOnMap}) async {
    if (_isLocating) return null;

    _isLocating = true;
    notifyListeners();

    try {
      final position = await _locationService.getCurrentPosition();
      final target = LatLng(position.latitude, position.longitude);

      _userLocation = target;
      _rebuildMarkers();

      // 🔥 вот здесь
      _updateHighlightedDistance();

      final controller = mapController;
      if (_isMapReady && centerOnMap && controller != null) {
        controller.move(target, 17);
      }

      return null;
    } on LocationPermissionException catch (e) {
      debugPrint('LocationPermissionException: ${e.message}');
      return e.message ?? 'Нет доступа к геолокации';
    } on LocationServiceException catch (e) {
      debugPrint('LocationServiceException: ${e.message}');
      return e.message ?? 'Служба геолокации недоступна';
    } catch (e) {
      debugPrint('Ошибка определения местоположения: $e');
      return 'Не удалось определить местоположение';
    } finally {
      _isLocating = false;
      notifyListeners();
    }
  }

  Future<String?> centerToUser() async {
    final controller = mapController;
    if (_userLocation != null) {
      if (_isMapReady && controller != null) {
        controller.move(_userLocation!, 17);
      }
      return null;
    }

    return _requestUserLocation(centerOnMap: true);
  }

  void _fitToBounds(LatLngBounds bounds) {
    if (!_isMapReady) return;

    try {
      final cameraFit = CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(32),
      );
      final controller = mapController;
      if (controller != null) {
        controller.fitCamera(cameraFit);
      }
    } catch (e) {
      debugPrint('fitToBounds error: $e');
    }
  }

  // ===== ТАП ПО КАРТЕ → запрос мест рядом =====

  Future<void> handleMapTap(LatLng point, {int? cityId}) async {
    // убираем подсветку места и маршрут
    _highlightedPlace = null;
    _highlightedPlaceId = null;
    _polylines.clear();

    _tapError = null;
    _tapResult = null;
    _isTapLoading = true;
    notifyListeners();

    try {
      final result = await _mapClickService.fetchPlacesByPoint(
        lat: point.latitude,
        lng: point.longitude,
        radiusM: 60,
        cityId: cityId,
      );
      _tapResult = result;
    } catch (e) {
      debugPrint('Ошибка загрузки мест по точке: $e');
      _tapError = 'Не удалось загрузить места рядом';
    } finally {
      _isTapLoading = false;
      notifyListeners();
    }
  }

  double? _computeDistanceKmForHighlighted() {
    if (_userLocation == null || _highlightedPlace == null) return null;

    final pLat = _highlightedPlace!.latitude;
    final pLng = _highlightedPlace!.longitude;
    if (pLat == null || pLng == null) return null;

    final distance = const Distance();
    final km = distance.as(
      LengthUnit.Kilometer,
      _userLocation!,
      LatLng(pLat, pLng),
    );

    // округлим как на бэке: 1 знак после запятой
    return double.parse(km.toStringAsFixed(1));
  }

  void _updateHighlightedDistance() {
    final km = _computeDistanceKmForHighlighted();
    if (km == null) return;

    // если модель мутируемая
    _highlightedPlace = _highlightedPlace!.copyWith(distanceKm: km);

    // если у тебя иммутабельная модель — через copyWith:
    // _highlightedPlace = _highlightedPlace!.copyWith(distanceKm: km);

    notifyListeners();
  }

  // ===== маркеры =====

  void _rebuildMarkers() {
    final markers = <Marker>[];

    // берём уже отфильтрованные места
    final placesToRender = _applyCategoryFilter(_places);

    // 1) маркеры по placesToRender
    for (final place in placesToRender) {
      if (place.latitude == null || place.longitude == null) continue;

      final isHighlighted = place.id == _highlightedPlaceId;

      markers.add(
        Marker(
          point: LatLng(place.latitude!, place.longitude!),
          width: isHighlighted ? 40 : 32,
          height: isHighlighted ? 40 : 32,
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () => _selectPlace(place.id),
            child: _buildPlaceMarkerIcon(isHighlighted),
          ),
        ),
      );
    }

    // 2) отдельный маркер для подсвеченного места, если его нет в _places
    final hp = _highlightedPlace;
    if (hp != null &&
        hp.latitude != null &&
        hp.longitude != null &&
        !_places.any((p) => p.id == hp.id)) {
      markers.add(
        Marker(
          point: LatLng(hp.latitude!, hp.longitude!),
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () => _selectPlace(hp.id),
            child: _buildPlaceMarkerIcon(true),
          ),
        ),
      );
    }

    // 3) маркер пользователя
    if (_userLocation != null) {
      markers.add(
        Marker(
          point: _userLocation!,
          width: 46,
          height: 46,
          alignment: Alignment.center,
          child: _buildUserLocationMarker(),
        ),
      );
    }

    _markers = markers;
  }

  Widget _buildPlaceMarkerIcon(bool isHighlighted) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isHighlighted ? Colors.blueAccent : Colors.redAccent,
        shape: BoxShape.circle,
        boxShadow: [
          if (isHighlighted)
            BoxShadow(color: Colors.blueAccent.withOpacity(0.4), blurRadius: 8),
        ],
      ),
      child: const Icon(Icons.location_on, size: 20, color: Colors.white),
    );
  }

  Widget _buildUserLocationMarker() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.9, end: 1.2),
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blueAccent.withOpacity(0.2),
        ),
        padding: const EdgeInsets.all(6),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blueAccent,
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.5),
                blurRadius: 10,
              ),
            ],
          ),
          padding: const EdgeInsets.all(4),
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // mapController?.dispose();
    super.dispose();
  }
}
