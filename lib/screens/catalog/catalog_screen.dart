import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/models/category.dart';
import 'package:mobile/providers/category_provider.dart';
import 'package:mobile/providers/city_provider.dart';
import 'package:mobile/providers/place_provider.dart';
import 'package:mobile/screens/catalog/widgets/category_card.dart';
import 'package:mobile/widgets/app_bar.dart';
import 'package:mobile/widgets/base_layout.dart';
import 'package:mobile/widgets/custom_pull_to_refresh.dart';
import 'package:mobile/widgets/place_card.dart';
import 'package:mobile/widgets/swipe_back_wrapper.dart';
import 'package:mobile/widgets/places_filter_bar.dart';
import 'package:provider/provider.dart';
import 'package:mobile/utils/category_navigation.dart';
import 'package:mobile/widgets/city_picker.dart';

enum CatalogViewMode { grid, list }

class CatalogScreen extends StatefulWidget {
  final int? categoryId;

  const CatalogScreen({super.key, this.categoryId});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  bool _placesRequested = false;
  CatalogViewMode _viewMode = CatalogViewMode.grid; // по умолчанию плитка

  @override
  void initState() {
    super.initState();

    if (widget.categoryId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _requestPlacesForCurrentCategory();
      });
    }
  }

  @override
  void didUpdateWidget(covariant CatalogScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.categoryId != widget.categoryId) {
      _placesRequested = false;
      if (widget.categoryId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _requestPlacesForCurrentCategory();
        });
      }
    }
  }

  Future<void> _openCategoryOnMap(CategoryModel category) async {
    // фильтр уже настроен в _requestPlacesForCurrentCategory,
    // так что просто идём на карту, используя текущие places из PlaceProvider
    if (!mounted) return;

    context.push(
      '/map',
      extra: {
        'categoryId': category.id,
        'categoryName': category.name,
        'categoryIcon': category.icon, // или icon, как у тебя в модели
      },
    );
  }

  void _toggleViewMode() {
    setState(() {
      _viewMode =
          _viewMode == CatalogViewMode.grid
              ? CatalogViewMode.list
              : CatalogViewMode.grid;
    });
  }

  void _requestPlacesForCurrentCategory() {
    if (!mounted) return;
    if (_placesRequested) return;
    if (widget.categoryId == null) return;

    final cityId = context.read<CityProvider>().currentCityId;
    if (cityId == null) return;

    final placeProvider = context.read<PlaceProvider>();
    final currentFilter = placeProvider.filter;

    placeProvider.updateFilter(
      currentFilter.copyWith(cityId: cityId, categoryId: widget.categoryId),
    );

    placeProvider.fetchPlaces(refresh: true);
    _placesRequested = true;
  }

  // ---------- шапка секции (заголовок + переключатель сетки) ----------

  Widget _buildSectionHeader(String title) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            tooltip: _viewMode == CatalogViewMode.grid ? 'Список' : 'Плитка',
            icon: Icon(
              _viewMode == CatalogViewMode.grid
                  ? Icons.view_agenda_outlined
                  : Icons.grid_view_rounded,
            ),
            onPressed: _toggleViewMode,
          ),
        ],
      ),
    );
  }

  // ---------- КОРЕНЬ КАТАЛОГА ----------

  Widget _buildRootContent(List<CategoryModel> categories) {
    if (categories.isEmpty) {
      return const Center(child: Text('Категорий пока нет'));
    }

    final Widget listWidget;
    if (_viewMode == CatalogViewMode.grid) {
      listWidget = GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 72,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return CategoryCard(
            category: category,
            onTap: () => handleCategoryTap(context, category),
            compact: true,
          );
        },
      );
    } else {
      listWidget = ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return CategoryCard(
            category: category,
            onTap: () => handleCategoryTap(context, category),
            compact: false,
          );
        },
      );
    }

    // Шапка «Каталог» + переключатель, ниже скроллящийся список/сетка
    return Column(
      children: [
        _buildSectionHeader('Категории'),
        const SizedBox(height: 4),
        Expanded(child: listWidget),
      ],
    );
  }

  // ---------- ПОДКАТЕГОРИИ ВНУТРИ КАТЕГОРИИ ----------

  Widget _buildSubcategories(List<CategoryModel> children) {
    if (children.isEmpty) return const SizedBox.shrink();

    if (_viewMode == CatalogViewMode.grid) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 72,
        ),
        itemCount: children.length,
        itemBuilder: (context, index) {
          final child = children[index];
          return CategoryCard(
            category: child,
            onTap: () => handleCategoryTap(context, child),
            compact: true,
          );
        },
      );
    } else {
      return Column(
        children:
            children
                .map(
                  (child) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: CategoryCard(
                      category: child,
                      onTap: () => handleCategoryTap(context, child),
                      compact: false,
                    ),
                  ),
                )
                .toList(),
      );
    }
  }

  // ---------- КОНТЕНТ ДЛЯ ВНУТРЕННЕЙ КАТЕГОРИИ ----------

  Widget _buildCategoryContent(
    CategoryModel selectedCategory,
    PlaceProvider placeProvider,
  ) {
    final places = placeProvider.places;
    final isLoadingPlaces = placeProvider.isLoading;

    return ListView(
      // padding: const EdgeInsets.symmetric(vertical: 80),
      children: [
        // здесь вместо «Подкатегории» — имя категории + переключатель сетки
        _buildSectionHeader(selectedCategory.name),
        const SizedBox(height: 4),

        // подкатегории
        if (selectedCategory.children.isNotEmpty) ...[
          _buildSubcategories(selectedCategory.children),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              height: 1,
              thickness: 1,
              color: Theme.of(context).dividerColor.withValues(
                alpha: 0.6,
              ), // мягкий, можно поиграть с alpha
            ),
          ),
          const SizedBox(height: 4),
        ],

        // фильтры / сортировка
        const PlacesFilterBar(),
        const SizedBox(height: 4),

        // места
        if (isLoadingPlaces && places.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (!isLoadingPlaces && places.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('В этой категории пока нет мест'),
          )
        else ...[
          ...places
              .take(10)
              .map(
                (place) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: PlaceCard(
                    place: place,
                    onTap: () {
                      context.pushNamed(
                        'placeDetail',
                        pathParameters: {'placeId': place.id.toString()},
                      );
                    },
                  ),
                ),
              ),
          if (placeProvider.hasMore)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: OutlinedButton(
                onPressed: () {
                  context.push(
                    '/places',
                    extra: {'fallback': '/catalog/${selectedCategory.id}'},
                  );
                },
                child: const Text('Показать все места'),
              ),
            ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget screen = Consumer2<CategoryProvider, PlaceProvider>(
      builder: (context, categoryProvider, placeProvider, child) {
        final categories = categoryProvider.categories;
        final bool isRoot = widget.categoryId == null;

        CategoryModel? selectedCategory;
        if (!isRoot && widget.categoryId != null) {
          selectedCategory = categoryProvider.findCategoryById(
            widget.categoryId!,
          );
        }

        // --- выбираем контент внутри BaseLayout ---
        Widget content;

        // 1) самый первый загрузочный экран, данных ещё нет
        if (categoryProvider.isLoading && categories.isEmpty) {
          content = const Center(child: CircularProgressIndicator());
        }
        // 2) ошибка и данных тоже нет
        else if (categoryProvider.error != null && categories.isEmpty) {
          content = Center(child: Text(categoryProvider.error!));
        }
        // 3) нормальное состояние
        else if (isRoot) {
          content = _buildRootContent(categories);
        } else {
          if (selectedCategory == null) {
            content = const Center(child: Text('Категория не найдена'));
          } else {
            content = _buildCategoryContent(selectedCategory, placeProvider);
          }
        }

        return BaseLayout(
          title: '',
          currentIndex: 1,
          showBackButton: false,
          appBar: CatalogAppBar(
            isRoot: isRoot,
            canGoBack: !isRoot,
            onBack: () => context.pop(),
            onOpenMap:
                isRoot
                    ? () {
                      context.push('/map', extra: {'rootCategories': true});
                    }
                    : (selectedCategory != null
                        ? () => _openCategoryOnMap(selectedCategory!)
                        : null),
          ),
          child: CustomPullToRefresh(
            onRefresh: () async {
              final cityId = context.read<CityProvider>().currentCityId;
              if (cityId != null) {
                await context.read<CategoryProvider>().fetchCategoriesForCity(
                  cityId,
                  force: true,
                );

                if (widget.categoryId != null) {
                  await context.read<PlaceProvider>().fetchPlaces(
                    refresh: true,
                  );
                }
              }
            },
            slivers: [SliverFillRemaining(hasScrollBody: true, child: content)],
          ),
        );
      },
    );

    return widget.categoryId != null
        ? SwipeBackWrapper(fallbackRoute: '/catalog', child: screen)
        : screen;
  }
}

class CatalogAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isRoot;
  final bool canGoBack;
  final VoidCallback? onBack;

  // 👇 новый коллбек
  final VoidCallback? onOpenMap;

  const CatalogAppBar({
    super.key,
    required this.isRoot,
    this.canGoBack = false,
    this.onBack,
    this.onOpenMap, // 👈
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cityProvider = context.watch<CityProvider>();
    final cityName = cityProvider.currentCity?.name ?? 'Город';
    final bool canPop = Navigator.canPop(context);

    return AppBarContainer(
      child: Row(
        children: [
          // ===== ЛЕВАЯ ЧАСТЬ =====
          if (!isRoot && (canGoBack || canPop))
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (onBack != null) {
                  onBack!();
                } else {
                  Navigator.maybePop(context);
                }
              },
            )
          else if (!isRoot)
            const SizedBox(width: 48)
          else
            const SizedBox.shrink(),

          // ===== ЦЕНТР / ЛЕВАЯ ЗОНА =====
          Expanded(
            child: Align(
              alignment: isRoot ? Alignment.centerLeft : Alignment.center,
              child:
                  isRoot
                      ? InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: () => showCityPickerSheet(context),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              cityName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.expand_more,
                              size: 18,
                              color: theme.colorScheme.outline,
                            ),
                          ],
                        ),
                      )
                      : const SizedBox.shrink(),
            ),
          ),

          // ===== ПРАВАЯ ЧАСТЬ (map + search) =====
          if (onOpenMap != null)
            IconButton(
              icon: const Icon(Icons.map_outlined),
              tooltip: isRoot ? 'Карта категорий' : 'Показать на карте',
              onPressed: onOpenMap,
            ),

          IconButton(
            icon: const Icon(Icons.search),
            onPressed:
                () => context.push('/search', extra: {'useLayout': false}),
          ),
        ],
      ),
    );
  }
}
