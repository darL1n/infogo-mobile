import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/models/map_place.dart';
import 'package:mobile/providers/category_provider.dart';
import 'package:mobile/screens/map/widgets/category_details_sheet.dart';
import 'package:mobile/screens/map/widgets/map_place_main_content.dart';
import 'package:mobile/screens/map/widgets/map_root_categories_sheet.dart';
import 'package:mobile/screens/map/widgets/place_bottom_bar.dart';
import 'package:provider/provider.dart';
import 'package:mobile/config/maptiler_config.dart';
import 'package:mobile/providers/city_provider.dart';
import 'package:mobile/providers/map_provider.dart';
import 'widgets/map_controls.dart';
import 'widgets/map_tap_bottom_sheet.dart';
import 'widgets/location_permission_sheet.dart';
import 'package:share_plus/share_plus.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapProvider? _mapProvider;
  late final MapController _mapController; // 👈
  late final DraggableScrollableController _sheetController; // 👈 добавили

  int? _categoryId;
  String? _categoryName;
  String? _categoryIcon;
  bool _didInit = false;

  bool _rootCategoriesMode = false;

  double _sheetExtent = 0.0;

  String _currentSheetMode = 'none';

  // 📦 Конфиг для sheet'а
  static const double _sheetMin = 0.22;
  static const double _sheetMax = 0.9;

  static const double _sheetInitialRoot = 0.5;
  static const double _sheetInitialCategory = 0.5;
  static const double _sheetInitialPlace = 0.5;

  @override
  void initState() {
    super.initState();
    _mapController = MapController(); // каждый MapScreen — свой контроллер
    _sheetController = DraggableScrollableController(); // 👈
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _mapProvider ??= context.read<MapProvider>();
    _mapProvider!.mapController = _mapController; // 👈 подсунули

    // чтобы не переинициализировать карту при каждом вызове didChangeDependencies
    if (_didInit) return;
    _didInit = true;

    _mapProvider!.resetMap(notify: false);

    final cityProvider = context.read<CityProvider>();
    final cityId = cityProvider.currentCityId;

    int? highlightId;
    List<int>? placeIds;
    int? categoryId;

    String? categoryName;
    String? categoryIcon;
    bool rootCategoriesMode = false; // 👈 новый локальный флаг

    final extra = GoRouterState.of(context).extra;
    if (extra is Map) {
      final rawHighlight = extra['highlightPlaceId'];
      final rawPlaceIds = extra['placeIds'];
      final rawCategoryId = extra['categoryId'];
      final rawCategoryName = extra['categoryName'];
      final rawCategoryIcon = extra['categoryIcon'];
      final rawRootCategories = extra['rootCategories']; // 👈

      if (rawHighlight is int) {
        highlightId = rawHighlight;
      }
      if (rawPlaceIds is List) {
        placeIds = rawPlaceIds.whereType<int>().toList();
      }
      if (rawCategoryId is int) {
        categoryId = rawCategoryId;
      }

      if (rawCategoryName is String) {
        categoryName = rawCategoryName;
      }
      if (rawCategoryIcon is String) {
        categoryIcon = rawCategoryIcon;
      }
      if (rawRootCategories is bool && rawRootCategories) {
        rootCategoriesMode = true;
      }
    }

    _categoryId = categoryId;
    _categoryName = categoryName;
    _categoryIcon = categoryIcon;
    _rootCategoriesMode = rootCategoriesMode;

    debugPrint(
      '[MapScreen] init: highlight=$highlightId, '
      'placeIds=${placeIds?.length}, categoryId=$_categoryId, '
      'rootMode=$_rootCategoriesMode, cityId=$cityId',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || cityId == null) return;

      // 1️⃣ Режим "Показать на карте" для одного места
      if (highlightId != null) {
        await _mapProvider!.initForHighlight(highlightId);
        return;
      }

      // 2️⃣ Режим "карта по списку мест" (из /places)
      if (placeIds != null && placeIds.isNotEmpty) {
        final filter = MapPlaceFilter(cityId: cityId, placeIds: placeIds);
        await _mapProvider!.initWithFilter(filter);
        return;
      }

      // 3️⃣ Режим "карта категории" (кнопка на категории)
      if (categoryId != null) {
        final filter = MapPlaceFilter(cityId: cityId, categoryId: categoryId);
        await _mapProvider!.initWithFilter(filter);
        return;
      }

      // 4️⃣ Глобальная карта города (без фильтра — просто все места)
      _mapProvider!.initPlain();
    });
  }

  void _collapseSheetToMin() {
    if (!_sheetController.isAttached) return;

    // если уже почти на минимуме — ничего не делаем
    if (_sheetController.size <= _sheetMin + 0.01) return;

    _sheetController.animateTo(
      _sheetMin,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
    );
  }

  // 👇 ДОБАВЬ ЭТО СЮДА (до build / после констант — неважно)
  void _handlePlaceClose() {
    final mp = context.read<MapProvider>();

    // 1️⃣ Если мы в режиме категории — просто скрываем карточку
    if (_categoryId != null) {
      mp.clearHighlight();
      return;
    }

    // 2️⃣ Категории нет → хотим показать root-каталог
    setState(() {
      _rootCategoriesMode = true;
    });

    // сбрасываем подсветку, фильтр и маркеры,
    // как при возврате к root из CategoryPlacesBody
    mp.clearHighlight();
    mp.setCategoryFilter('all');
    mp.initPlain();
  }

  @override
  Widget build(BuildContext context) {
    final mapProvider = context.watch<MapProvider>();
    final cityProvider = context.watch<CityProvider>();

    if (_rootCategoriesMode) {
      final categoryProvider = context.read<CategoryProvider>();
      final cityIdForCats = cityProvider.currentCityId;

      if (cityIdForCats != null &&
          !categoryProvider.isLoaded &&
          !categoryProvider.isLoading) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          categoryProvider.fetchCategoriesForCity(cityIdForCats);
        });
      }
    }

    // Центр города — фолбек, если геолокация недоступна
    final initialLat = cityProvider.currentCity?.latitude ?? 41.0188;
    final initialLng = cityProvider.currentCity?.longitude ?? 70.0846;
    final initialCenter = LatLng(initialLat, initialLng);

    // 👉 границы города
    final angrenBounds = LatLngBounds(
      LatLng(40.95, 69.95),
      LatLng(41.08, 70.25),
    );

    // Глобальный лоадер:
    final bool showGlobalLoader =
        !mapProvider.openedWithHighlight &&
        mapProvider.isLocating &&
        mapProvider.userLocation == null;

    // ===== Sheet-мод: определяем режим =====
    final bool hasPlace = mapProvider.highlightedPlace != null;
    final bool hasCategory = _categoryId != null;
    final bool inRoot = _rootCategoriesMode;

    // определяем целевой режим шторки
    final String sheetMode =
        hasPlace
            ? 'place'
            : hasCategory
            ? 'category'
            : inRoot
            ? 'root'
            : 'none';

    // целевой размер по режиму
    final double targetSize =
        sheetMode == 'place'
            ? _sheetInitialPlace
            : sheetMode == 'category'
            ? _sheetInitialCategory
            : sheetMode == 'root'
            ? _sheetInitialRoot
            : _sheetMin;

    // initialChildSize для первого появления шторки
    final double sheetInitialSize = targetSize;

    // 🔹 если режим поменялся и контроллер уже прикреплён — анимируем к нужному размеру
    if (sheetMode != _currentSheetMode && _sheetController.isAttached) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_sheetController.isAttached) return;

        _sheetController.animateTo(
          targetSize,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        );
      });

      // тут setState не нужен, это внутренний «тех.флаг»
      _currentSheetMode = sheetMode;
    }

    return Stack(
      children: [
        Listener(
          // любой тач/жест по карте → свернуть шторку
          onPointerDown: (_) => _collapseSheetToMin(),
          onPointerSignal:
              (_) => _collapseSheetToMin(), // колесо мыши/особые сигналы
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: 14,
              minZoom: 11,
              maxZoom: 19,
              cameraConstraint: CameraConstraint.contain(bounds: angrenBounds),
              onMapReady:
                  () => mapProvider.onMapReady(cityBounds: angrenBounds),
              onTap: (tapPosition, point) {
                final mapProviderRead = context.read<MapProvider>();
                final city = context.read<CityProvider>().currentCity;

                // запускаем загрузку мест вокруг точки
                mapProviderRead.handleMapTap(point, cityId: city?.id);

                if (!mounted) return;

                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) {
                    return ChangeNotifierProvider.value(
                      value: mapProviderRead,
                      child: MapTapBottomSheet(tapPoint: point),
                    );
                  },
                );
              },
            ),
            children: [
              TileLayer(
                urlTemplate: MapTilerConfig.tilesUrl,
                userAgentPackageName: 'uz.infogo.app',
                tileDimension: 256,
              ),
              if (mapProvider.polylines.isNotEmpty)
                PolylineLayer(polylines: mapProvider.polylines),
              MarkerLayer(markers: mapProvider.markers),
            ],
          ),
        ),

        if (showGlobalLoader)
          Container(
            color: Colors.white,
            child: const Center(child: CircularProgressIndicator()),
          ),

        // 🔹 Контролы справа сверху
        Positioned(
          right: 14,
          top: 14,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MapZoomButton(
                icon: Icons.add,
                onPressed: () {
                  _collapseSheetToMin(); // 👈
                  final camera = _mapController.camera;
                  final newZoom = (camera.zoom + 1).clamp(3.0, 19.0);
                  _mapController.move(camera.center, newZoom);
                },
              ),
              const SizedBox(height: 6),
              MapZoomButton(
                icon: Icons.remove,
                onPressed: () {
                  _collapseSheetToMin(); // 👈
                  final camera = _mapController.camera;
                  final newZoom = (camera.zoom - 1).clamp(3.0, 19.0);
                  _mapController.move(camera.center, newZoom);
                },
              ),
              const SizedBox(height: 16),
              MyLocationButton(
                isLoading: mapProvider.isLocating,
                onPressed: () async {
                  _collapseSheetToMin(); // 👈
                  final error = await mapProvider.centerToUser();

                  if (error != null && context.mounted) {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) {
                        return LocationPermissionSheet(
                          message: error,
                          onOpenSettings: () async {
                            await mapProvider.openLocationSettings();
                            if (context.mounted) Navigator.of(context).pop();
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),

        // 🔹 режим "подсвеченное место / категория / root-каталог" — общий sheet
        if (_rootCategoriesMode ||
            _categoryId != null ||
            mapProvider.highlightedPlace != null)
          NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              setState(() {
                _sheetExtent = notification.extent; // 0.18 .. 0.9
              });
              return false;
            },
            child: DraggableScrollableSheet(
              controller: _sheetController,
              // key: ValueKey<String>(sheetModeKey),
              initialChildSize: sheetInitialSize,
              minChildSize: _sheetMin,
              maxChildSize: _sheetMax,

              snap: true,
              snapSizes: const [
                _sheetMin, // 0.18
                0.5, // условная “середина”
                _sheetMax, // 0.9
              ],

              snapAnimationDuration: const Duration(
                milliseconds: 200,
              ), // можно настроить
              builder: (context, scrollController) {
                // 1️⃣ Детали места
                if (mapProvider.highlightedPlace != null) {
                  final place = mapProvider.highlightedPlace!;

                  // 👇 если шторка ещё ни разу не шевелилась (_sheetExtent == 0),
                  // используем стартовый размер для места (_sheetInitialPlace)
                  final effectiveExtent =
                      _sheetExtent == 0.0 ? _sheetInitialPlace : _sheetExtent;

                  final showBottomBar = effectiveExtent > 0.35;

                  // ⭐ избранное (пока заглушка)
                  final bool isFavorite =
                      false; // потом возьмёшь из FavoriteProvider

                  void toggleFavorite() {
                    debugPrint('toggleFavorite for place ${place.id}');
                    // context.read<FavoriteProvider>().toggle(place);
                  }

                  // 🔗 поделиться
                  void sharePlace() {
                    final parts = <String>[];

                    parts.add(place.name);

                    if ((place.address ?? '').isNotEmpty) {
                      parts.add(place.address!);
                    }

                    // 👇 Человекопонятная ссылка на место
                    final url = 'https://infogo.uz/place/${place.id}';
                    parts.add(url);

                    final text = parts.join('\n');

                    // ignore: deprecated_member_use
                    Share.share(text);
                  }

                  return SafeArea(
                    top: false,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 16,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // скроллимый контент
                          Expanded(
                            child: CustomScrollView(
                              controller: scrollController,
                              slivers: [
                                SliverToBoxAdapter(
                                  child: MapPlaceMainContent(
                                    place: place,
                                    onRoutePressed:
                                        () => mapProvider
                                            .buildRouteToHighlighted(context),
                                    onOpenDetails: () {
                                      GoRouter.of(context).pushNamed(
                                        'placeDetail',
                                        pathParameters: {
                                          'placeId': place.id.toString(),
                                        },
                                      );
                                    },
                                    onClose: _handlePlaceClose,
                                    onShare: sharePlace,
                                    onToggleFavorite: toggleFavorite,
                                    isFavorite: isFavorite,
                                    showHandle: true,
                                    showImage: true,
                                    showDescription: true,
                                    showActions: false, // кнопки в нижнем баре
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      8,
                                      16,
                                      16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // фиксированный нижний бар
                          AnimatedSize(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            child:
                                showBottomBar
                                    ? PlaceBottomBar(
                                      onRoutePressed:
                                          () => mapProvider
                                              .buildRouteToHighlighted(context),
                                      onOpenDetails: () {
                                        GoRouter.of(context).pushNamed(
                                          'placeDetail',
                                          pathParameters: {
                                            'placeId': place.id.toString(),
                                          },
                                        );
                                      },
                                    )
                                    : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // 2️⃣ Режим выбранной категории
                if (_categoryId != null) {
                  return SafeArea(
                    top: false,
                    child: CategoryPlacesBody(
                      scrollController: scrollController,
                      categoryName: _categoryName,
                      categoryIcon: _categoryIcon,
                      onBackToRoot: () {
                        // 🔹 сбрасываем состояние в root-режим
                        setState(() {
                          _categoryId = null;
                          _categoryName = null;
                          _categoryIcon = null;
                          _rootCategoriesMode = true;
                        });

                        // 🔹 сброс фильтра карты и маркеров (как при первом root-открытии)
                        final mp = context.read<MapProvider>();
                        mp.setCategoryFilter('all');
                        mp.initPlain();
                      },
                    ),
                  );
                }

                // 3️⃣ Root-категории
                return SafeArea(
                  top: false,
                  child: MapRootCategoriesSheet(
                    scrollController: scrollController,
                    onCategorySelected: (category) async {
                      final cityId = context.read<CityProvider>().currentCityId;
                      final mp = _mapProvider;
                      if (cityId == null || mp == null) return;

                      final filter = MapPlaceFilter(
                        cityId: cityId,
                        categoryId: category.id,
                      );

                      // 1️⃣ грузим маркеры категории
                      await mp.initWithFilter(filter);

                      if (!mounted) return;

                      // 3️⃣ переключаем UI в режим категории
                      setState(() {
                        _categoryId = category.id;
                        _categoryName = category.name;
                        _categoryIcon = category.icon;
                        _rootCategoriesMode = false;
                      });
                    },
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    // _mapProvider?.resetMap(notify: false);
    _mapProvider?.mapController = null; // отвязали
    _mapController.dispose(); // убили контроллер этого экрана
    _sheetController.dispose(); // 👈
    super.dispose();
  }
}
