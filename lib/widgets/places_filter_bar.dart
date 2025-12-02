import 'package:flutter/material.dart';
import 'package:mobile/models/place_filter.dart';
import 'package:mobile/providers/place_provider.dart';
import 'package:provider/provider.dart';

class PlacesFilterBar extends StatelessWidget {
  const PlacesFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final placeProvider = context.watch<PlaceProvider>();
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyMedium;
    final filter = placeProvider.filter;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),

        // Чипы фильтров
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              FilterChip(
                label: Text('Открыто сейчас', style: textStyle),
                selected: filter.openNow,
                onSelected: (value) async {
                  placeProvider.updateFilter(
                    filter.copyWith(openNow: value),
                  );
                  await placeProvider.fetchPlaces(refresh: true);
                },
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: Text('Рядом', style: textStyle),
                selected: filter.nearby,
                onSelected: (value) async {
                  placeProvider.updateFilter(
                    filter.copyWith(nearby: value),
                  );
                  await placeProvider.fetchPlaces(refresh: true);
                },
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: Text('Высокий рейтинг', style: textStyle),
                selected: filter.highRated,
                onSelected: (value) async {
                  placeProvider.updateFilter(
                    filter.copyWith(highRated: value),
                  );
                  await placeProvider.fetchPlaces(refresh: true);
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Сортировка + "Фильтры"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _showSortBottomSheet(context, placeProvider),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.sort, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        _sortLabel(filter.sort),
                        style: textStyle,
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.expand_more, size: 18),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  // TODO: открыть расширенные фильтры
                },
                icon: const Icon(Icons.tune, size: 18),
                label: const Text('Фильтры'),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 4),
      ],
    );
  }

  Future<void> _showSortBottomSheet(
    BuildContext context,
    PlaceProvider placeProvider,
  ) async {
    final theme = Theme.of(context);
    final current = placeProvider.filter.sort;

    final result = await showModalBottomSheet<PlaceSort>(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Сортировка',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              _SortOptionTile(
                title: 'Популярное',
                subtitle: 'Рекомендованные и самые посещаемые',
                value: PlaceSort.popular,
                groupValue: current,
                onSelected: () =>
                    Navigator.pop(context, PlaceSort.popular),
              ),
              _SortOptionTile(
                title: 'По рейтингу',
                subtitle: 'Сначала места с высокой оценкой',
                value: PlaceSort.rating,
                groupValue: current,
                onSelected: () =>
                    Navigator.pop(context, PlaceSort.rating),
              ),
              _SortOptionTile(
                title: 'По расстоянию',
                subtitle: 'Ближайшие места выше в списке',
                value: PlaceSort.distance,
                groupValue: current,
                onSelected: () =>
                    Navigator.pop(context, PlaceSort.distance),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (result != null && result != current) {
      placeProvider.updateFilter(
        placeProvider.filter.copyWith(sort: result),
      );
      await placeProvider.fetchPlaces(refresh: true);
    }
  }
}

class _SortOptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final PlaceSort value;
  final PlaceSort groupValue;
  final VoidCallback onSelected;

  const _SortOptionTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = value == groupValue;

    return ListTile(
      onTap: onSelected,
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: selected ? theme.colorScheme.primary : theme.iconTheme.color,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall,
      ),
    );
  }
}

String _sortLabel(PlaceSort sort) {
  switch (sort) {
    case PlaceSort.popular:
      return 'Популярное';
    case PlaceSort.rating:
      return 'По рейтингу';
    case PlaceSort.distance:
      return 'По расстоянию';
  }
}
