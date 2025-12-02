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
import 'package:mobile/widgets/places_filter_bar.dart'; // 👈 НОВЫЙ ИМПОРТ
import 'package:provider/provider.dart';

class PlacesScreen extends StatefulWidget {
  const PlacesScreen({super.key});

  @override
  State<PlacesScreen> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends State<PlacesScreen> {
  late PlaceProvider _placeProvider;

  @override
  void initState() {
    super.initState();
    _placeProvider = Provider.of<PlaceProvider>(context, listen: false);

    // ⚙️ первый запрос по уже установленному фильтру (categoryId + cityId)
    Future.microtask(() => _placeProvider.fetchPlaces(refresh: true));
  }

  @override
  void dispose() {
    // по выходу чистим список
    Future.microtask(() => _placeProvider.clearPlaces());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // достаём fallback, который ты кладёшь в extra в handleCategoryTap
    final extra = GoRouterState.of(context).extra;
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
            final categoryId = filter.categoryId;

            CategoryModel? category;
            if (categoryId != null) {
              final catProvider =
                  Provider.of<CategoryProvider>(context, listen: false);
              category = catProvider.findCategoryById(categoryId);
            }

            return BaseLayout(
              title: category?.name ?? 'Места',
              currentIndex: 1, // вкладка «Каталог»
              appBar: PlacesAppBar(fallbackRoute: fallbackRoute),
              showBackButton: true,
              child: CustomPullToRefresh(
                onRefresh: () async {
                  await _placeProvider.fetchPlaces(refresh: true);
                },
                slivers: [
                  // Заголовок категории: «Кафе • Мест: 24»
                  if (category != null)
                    SliverToBoxAdapter(
                      child: _CategoryHeader(category: category),
                    ),

                  // Фильтры / сортировка — теперь общий виджет
                  const SliverToBoxAdapter(
                    child: PlacesFilterBar(),
                  ),

                  // Список мест
                  ..._buildPlaceSlivers(context, placeProvider),
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
    PlaceProvider placeProvider,
  ) {
    if (placeProvider.isLoading && placeProvider.places.isEmpty) {
      return const [
        SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (!placeProvider.isLoading && placeProvider.places.isEmpty) {
      return const [
        SliverFillRemaining(
          child: Center(child: Text('Нет мест для отображения')),
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

// Заголовок категории, как раньше
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
