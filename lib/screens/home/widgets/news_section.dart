// lib/screens/home/widgets/news_section.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:mobile/providers/city_provider.dart';
import 'package:mobile/providers/news_provider.dart';
import 'package:mobile/models/news.dart';

class NewsSection extends StatefulWidget {
  final String? cityName;

  const NewsSection({super.key, this.cityName});

  @override
  State<NewsSection> createState() => _NewsSectionState();
}

class _NewsSectionState extends State<NewsSection> {
  bool _requested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_requested) return;

    final cityId = context.read<CityProvider>().currentCityId;
    if (cityId == null) return; // город ещё не выбран — ждём

    _requested = true;

    // важно: дергаем провайдер после первого кадра,
    // чтобы не было "setState() or markNeedsBuild() called during build"
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewsProvider>().loadHomeFeatured(cityId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final fallbackCityName =
        context.watch<CityProvider>().currentCity?.name ?? 'городе';
    final cityLabel = widget.cityName ?? fallbackCityName;

    return Consumer<NewsProvider>(
      builder: (context, newsProv, _) {
        final List<NewsModel> items = newsProv.homeNews;
        final bool loading = newsProv.homeLoading;

        // первая загрузка — скелетон
        if (loading && items.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _NewsSectionSkeleton(cityLabel: cityLabel),
          );
        }

        // загрузка завершена, но новостей нет — просто скрываем блок
        if (!loading && items.isEmpty) {
          return const SizedBox.shrink();
        }

        // маппим NewsModel → _NewsItemData
        final rows = items.map<_NewsItemData>((n) {
          final tag = n.categoryName ?? 'Новость';
          return _NewsItemData(
            id: n.id,
            title: n.title,
            tag: tag,
          );
        }).toList();

        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // заголовок
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Новости о $cityLabel',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        context.push('/news');
                      },
                      label: const Text('Все'),
                      icon: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // карточка с новостями
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.03),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      for (int i = 0; i < rows.length; i++) ...[
                        _NewsRow(item: rows[i]),
                        if (i != rows.length - 1)
                          Divider(
                            height: 8,
                            indent: 16,
                            endIndent: 16,
                            color: scheme.outlineVariant
                                .withValues(alpha: 0.5),
                          ),
                      ],
                    ],
                  ),
                ),
              ),

              if (loading && items.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.only(left: 24, top: 4),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _NewsItemData {
  final int id;
  final String title;
  final String tag;

  _NewsItemData({
    required this.id,
    required this.title,
    required this.tag,
  });
}

class _NewsRow extends StatelessWidget {
  final _NewsItemData item;

  const _NewsRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return InkWell(
      onTap: () {
        context.push('/news/${item.id}');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 10, top: 2),
              decoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // заголовок новости — максимум 2 строки, ellipsis
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // тег (категория)
                  Text(
                    item.tag,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: scheme.outline.withValues(alpha: 0.8),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewsSectionSkeleton extends StatelessWidget {
  final String cityLabel;

  const _NewsSectionSkeleton({required this.cityLabel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // заголовок
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Новости о $cityLabel',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  width: 60,
                  height: 16,
                  decoration: BoxDecoration(
                    color: scheme.surfaceVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ],
            ),
          ),

          // skeleton-карточка
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.03),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: List.generate(3, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(
                            right: 10,
                            top: 2,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.surfaceVariant,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 12,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: scheme.surfaceVariant,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                height: 10,
                                width: 80,
                                decoration: BoxDecoration(
                                  color: scheme.surfaceVariant
                                      .withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
