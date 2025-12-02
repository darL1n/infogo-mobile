import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/models/category.dart';
import 'package:mobile/providers/category_provider.dart';
import 'package:mobile/providers/place_provider.dart';
import 'package:mobile/screens/places/widgets/places_app_bar.dart';
import 'package:mobile/widgets/base_layout.dart';
import 'package:mobile/widgets/custom_pull_to_refresh.dart';
import 'package:mobile/widgets/place_card.dart';
import 'package:mobile/widgets/swipe_back_wrapper.dart';
import 'package:mobile/widgets/places_filter_bar.dart';
import 'package:provider/provider.dart';

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late PlaceProvider _placeProvider;

  @override
  void initState() {
    super.initState();
    _placeProvider = Provider.of<PlaceProvider>(context, listen: false);

    // первый запрос по уже установленному фильтру (query / categoryId / cityId)
    Future.microtask(() => _placeProvider.fetchPlaces(refresh: true));
  }

  @override
  void dispose() {
    // по выходу чистим список, но не трогаем filter
    Future.microtask(() => _placeProvider.clearPlaces());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routerState = GoRouterState.of(context);
    final extra = routerState.extra;

    String? fallbackRoute;
    if (extra is Map && extra['fallback'] is String) {
      fallbackRoute = extra['fallback'] as String;
    }

    return SwipeBackWrapper(
      fallbackRoute: fallbackRoute ?? '/catalog',
      child: ChangeNotifierProvider.value(
        value: _placeProvider,
        child: Consumer<PlaceProvider>(
          builder: (context, placeProvider, child) {
            final filter = placeProvider.filter;

            final query = (filter.query ?? '').trim();
            final bool isSearchMode = query.isNotEmpty;

            final categoryId = filter.categoryId;
            CategoryModel? category;

            if (!isSearchMode && categoryId != null) {
              final catProvider =
                  Provider.of<CategoryProvider>(context, listen: false);
              category = catProvider.findCategoryById(categoryId);
            }

            final title = isSearchMode
                ? 'Результаты поиска'
                : (category?.name ?? 'Места');

            return BaseLayout(
              title: title,
              currentIndex: 1, // вкладка «Каталог»
              appBar: PlacesAppBar(fallbackRoute: fallbackRoute, query: isSearchMode ? query : null,),
              showBackButton: true,
              child: CustomPullToRefresh(
                onRefresh: () async {
                  await _placeProvider.fetchPlaces(refresh: true);
                },
                slivers: [
                  // 🔹 Шапка для ПОИСКА
                  if (isSearchMode)
                    SliverToBoxAdapter(
                      child: _SearchHeader(
                        query: query,
                        totalCount: placeProvider.places.length,
                        hasMore: placeProvider.hasMore,
                      ),
                    )
                  // 🔹 Шапка категории — если пришли из каталога
                  else if (category != null)
                    SliverToBoxAdapter(
                      child: _CategoryHeader(category: category),
                    ),

                  const SliverToBoxAdapter(
                    child: PlacesFilterBar(),
                  ),

                  ..._buildPlaceSlivers(
                    context,
                    placeProvider,
                    isSearchMode: isSearchMode,
                    query: query,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildPlaceSlivers(
    BuildContext context,
    PlaceProvider placeProvider, {
    required bool isSearchMode,
    required String query,
  }) {
    if (placeProvider.isLoading && placeProvider.places.isEmpty) {
      return const [
        SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (!placeProvider.isLoading && placeProvider.places.isEmpty) {
      final text = isSearchMode && query.isNotEmpty
          ? 'По запросу «$query» ничего не найдено'
          : 'Нет мест для отображения';

      return [
        SliverFillRemaining(
          child: Center(child: Text(text)),
        ),
      ];
    }

    return [
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index < placeProvider.places.length) {
              final place = placeProvider.places[index];
              return Padding(
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
              );
            }

            if (placeProvider.isLoading) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            return const SizedBox.shrink();
          },
          childCount:
              placeProvider.places.length + (placeProvider.hasMore ? 1 : 0),
        ),
      ),
    ];
  }
}

/// Шапка для режима КАТЕГОРИИ
class _CategoryHeader extends StatelessWidget {
  final CategoryModel category;

  const _CategoryHeader({required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Мест: ${category.placeCount}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

/// Шапка для режима ПОИСКА
class _SearchHeader extends StatelessWidget {
  final String query;
  final int totalCount;
  final bool hasMore;

  const _SearchHeader({
    required this.query,
    required this.totalCount,
    required this.hasMore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final countText = totalCount == 0
        ? 'Ничего не найдено'
        : hasMore
            ? '$totalCount+ мест найдено'
            : '$totalCount мест найдено';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'По запросу',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '«$query»',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            countText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
