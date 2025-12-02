import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/providers/map_provider.dart';
import 'package:mobile/widgets/category_icon.dart';
import 'package:provider/provider.dart';

class CategoryPlacesBody extends StatefulWidget {
  final String? categoryName;
  final String? categoryIcon;
  final ScrollController scrollController;

  final VoidCallback? onBackToRoot;

  const CategoryPlacesBody({
    super.key,
    required this.scrollController,
    this.categoryName,
    this.categoryIcon,
    this.onBackToRoot,
  });

  @override
  State<CategoryPlacesBody> createState() => _CategoryPlacesBodyState();
}

class _CategoryPlacesBodyState extends State<CategoryPlacesBody> {
  // 🔹 простые фильтры "на будущее"
  static const _filters = <_CategoryFilter>[
    _CategoryFilter('all', 'Все места'),
    _CategoryFilter('rating', 'С высоким рейтингом'),
    _CategoryFilter('open', 'Сейчас открыто'),
    _CategoryFilter('events', 'С событиями'),
  ];

  String _selectedFilterId = 'all';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mapProvider = context.watch<MapProvider>();
    final places = mapProvider.placesForList;

    // пока фильтр логически не применяем — просто берём как есть
    final visiblePlaces = places;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: CustomScrollView(
        controller: widget.scrollController,
        slivers: [
          // 🔹 Хэндл + заголовок + чипы + (опционально) выбранное место
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Заголовок категории
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        if (widget.categoryIcon != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: CategoryIcon(
                              iconKey: widget.categoryIcon!,
                              size: 22,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            widget.categoryName ?? 'Места категории',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        // 🔹 Кнопка фильтров
                        IconButton(
                          icon: const Icon(Icons.filter_alt_outlined),
                          onPressed: () {
                            // TODO: отдельный экран/диалог фильтров
                          },
                        ),

                        // 🔹 Крестик "к категориям", если колбэк передан
                        if (widget.onBackToRoot != null)
                          IconButton(
                            icon: const Icon(Icons.close),
                            tooltip: 'К категориям',
                            onPressed: widget.onBackToRoot,
                          ),
                      ],
                    ),
                  ),

                  // 🔹 Чипы-фильтры
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: _filters.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final filter = _filters[index];
                        final isSelected = filter.id == _selectedFilterId;

                        return ChoiceChip(
                          label: Text(filter.label),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (!selected) {
                              return; // для красоты, чтобы не ловить "снятие" выбора
                            }

                            setState(() {
                              _selectedFilterId = filter.id;
                            });

                            // если уже добавил фильтрацию в провайдер – оставляешь:
                            context.read<MapProvider>().setCategoryFilter(
                              filter.id,
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Divider(height: 1),
                ],
              ),
            ),
          ),

          // 🔹 Контент: либо пустое состояние, либо список мест
          if (visiblePlaces.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  'В этой категории пока нет мест',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final place = visiblePlaces[index];
                final isSelected = mapProvider.highlightedPlaceId == place.id;

                return ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  title: Text(
                    place.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  selected: isSelected,
                  onTap: () {
                    context.read<MapProvider>().highlightPlace(place.id);
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      GoRouter.of(context).pushNamed(
                        'placeDetail',
                        pathParameters: {'placeId': place.id.toString()},
                      );
                    },
                  ),
                );
              }, childCount: visiblePlaces.length),
            ),
        ],
      ),
    );
  }
}

class _CategoryFilter {
  final String id;
  final String label;

  const _CategoryFilter(this.id, this.label);
}
