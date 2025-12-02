// lib/screens/news/news_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:mobile/providers/city_provider.dart';
import 'package:mobile/providers/news_provider.dart';
import 'package:mobile/models/news.dart';
import 'package:mobile/widgets/base_layout.dart';
import 'package:mobile/widgets/custom_pull_to_refresh.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  bool _requestedInit = false;

  String? _selectedCategory; // null = все категории
  String _search = '';

  late final TextEditingController _searchController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_requestedInit) return;

    final cityId = context.read<CityProvider>().currentCityId;
    if (cityId == null) return;

    _requestedInit = true;

    // Чтобы не поймать "setState during build", инициализируем после первого кадра
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewsProvider>().initForCity(cityId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 280), () {
      setState(() {
        _search = value.trim().toLowerCase();
      });
    });
  }

  bool _matchesFilter(NewsModel n) {
    final byCategory =
        _selectedCategory == null || n.categoryName == _selectedCategory;

    if (_search.isEmpty) return byCategory;

    final title = n.title.toLowerCase();
    // final short = (n.shortText ?? '').toLowerCase();

    final bySearch = title.contains(_search);

    return byCategory && bySearch;
  }

  @override
  Widget build(BuildContext context) {
    final city = context.watch<CityProvider>().currentCity;
    final cityName = city?.name ?? 'городе';

    final content = Consumer<NewsProvider>(
      builder: (context, newsProv, _) {
        final allNews = newsProv.news; // предполагаем, что так и назвали
        final isLoading = newsProv.isLoading;
        final error = newsProv.error;

        final filtered = allNews.where(_matchesFilter).toList();

        return CustomPullToRefresh(
          onRefresh: () async {
            final cityId = context.read<CityProvider>().currentCityId;
            if (cityId != null) {
              await context.read<NewsProvider>().initForCity(cityId);
            } else {
              await context.read<NewsProvider>().refresh();
            }
          },
          slivers: [
            // Хедер с описанием
            SliverToBoxAdapter(child: _HeaderBlock(cityName: cityName)),

            // Поиск + фильтры
            SliverToBoxAdapter(
              child: _FiltersBlock(
                controller: _searchController,
                onSearchChanged: _onSearchChanged,
                selectedCategory: _selectedCategory,
                onCategoryTap: (cat) {
                  setState(() {
                    _selectedCategory = _selectedCategory == cat ? null : cat;
                  });
                },
                allNews: allNews,
              ),
            ),

            // Состояния загрузки / ошибки / пусто
            if (isLoading && allNews.isEmpty)
              const SliverToBoxAdapter(child: _NewsListSkeleton())
            else if (error != null && allNews.isEmpty)
              SliverToBoxAdapter(child: _ErrorState(message: error))
            else if (!isLoading && filtered.isEmpty)
              SliverToBoxAdapter(child: _EmptyState())
            else
              SliverList.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
                    child: _NewsCard(news: item),
                  );
                },
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        );
      },
    );

    return BaseLayout(
      title: 'Новости города',
      currentIndex: 0,
      showBackButton: true,
      fallbackRoute: '/home',
      child: content,
    );
  }
}

// ---------- Хедер ----------

class _HeaderBlock extends StatelessWidget {
  final String cityName;

  const _HeaderBlock({required this.cityName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primary.withValues(alpha: 0.10),
              scheme.primary.withValues(alpha: 0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.article_outlined, color: scheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Новости в $cityName',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Собираем важное о городе: изменения, открытия, предупреждения и подсказки.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withValues(
                        alpha: 0.85,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Поиск + фильтры ----------

class _FiltersBlock extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String) onSearchChanged;
  final String? selectedCategory;
  final void Function(String category) onCategoryTap;
  final List<NewsModel> allNews;

  const _FiltersBlock({
    required this.controller,
    required this.onSearchChanged,
    required this.selectedCategory,
    required this.onCategoryTap,
    required this.allNews,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // категории (только из загруженных новостей)
    final categories =
        {
            for (final n in allNews)
              if (n.categoryName != null && n.categoryName!.trim().isNotEmpty)
                n.categoryName!.trim(),
          }.toList()
          ..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Поиск
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: TextField(
            controller: controller,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Поиск по новостям',
              isDense: true,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
            ),
          ),
        ),

        // Чипы категорий
        if (categories.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _CategoryChip(
                    label: 'Все',
                    isActive: selectedCategory == null,
                    onTap: () => onCategoryTap(''),
                  ),
                  const SizedBox(width: 8),
                  ...categories.map((cat) {
                    final active = selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _CategoryChip(
                        label: cat,
                        isActive: active,
                        onTap: () => onCategoryTap(cat),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color:
              isActive
                  ? scheme.primary.withValues(alpha: 0.12)
                  : scheme.surfaceVariant.withValues(alpha: 0.4),
          border: Border.all(
            color: isActive ? scheme.primary : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? scheme.primary : scheme.onSurface,
          ),
        ),
      ),
    );
  }
}

// ---------- Карточка новости ----------

class _NewsCard extends StatelessWidget {
  final NewsModel news;

  const _NewsCard({required this.news});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final dateLabel = formatNewsDateLabel(news.publishedAt);
    final tag = news.categoryName ?? 'Новость';

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          context.push(
            '/news/${news.id}',
            extra: news, // NewsModel
          );
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Верхняя строка: тег + дата
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      tag,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      dateLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.outline,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Заголовок
              Text(
                news.title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              // if ((news.shortText ?? '').trim().isNotEmpty) ...[
              //   const SizedBox(height: 6),
              //   Text(
              //     news.shortText!.trim(),
              //     maxLines: 3,
              //     overflow: TextOverflow.ellipsis,
              //     style: theme.textTheme.bodySmall?.copyWith(
              //       color: theme.textTheme.bodySmall?.color
              //           ?.withValues(alpha: 0.9),
              //     ),
              //   ),
              // ],
              const SizedBox(height: 8),

              Row(
                children: [
                  Icon(
                    Icons.open_in_new,
                    size: 16,
                    color: scheme.outline.withValues(alpha: 0.9),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Открыть новость",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.outline.withValues(alpha: 0.9),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: scheme.outline.withValues(alpha: 0.9),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- Скелетон / стейты ----------

class _NewsListSkeleton extends StatelessWidget {
  const _NewsListSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // верхняя строка
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 16,
                      decoration: BoxDecoration(
                        color: scheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 80,
                      height: 12,
                      decoration: BoxDecoration(
                        color: scheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: scheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 12,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: scheme.surfaceVariant.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: scheme.surfaceVariant,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: scheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: scheme.outline),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Пока нет новостей по текущим фильтрам. Попробуйте убрать поиск или выбрать другую категорию.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.outline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: scheme.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Хелпер форматирования даты ----------

String formatNewsDateLabel(DateTime? dt) {
  if (dt == null) return '';

  final local = dt.toLocal();
  final now = DateTime.now();

  final today = DateTime(now.year, now.month, now.day);
  final dateOnly = DateTime(local.year, local.month, local.day);
  final diff = dateOnly.difference(today).inDays;

  String dayPart;
  if (diff == 0) {
    dayPart = 'Сегодня';
  } else if (diff == -1) {
    dayPart = 'Вчера';
  } else {
    final day = local.day.toString().padLeft(2, '0');
    final month = _monthShort(local.month);
    dayPart = '$day $month';
  }

  final hh = local.hour.toString().padLeft(2, '0');
  final mm = local.minute.toString().padLeft(2, '0');

  return '$dayPart • $hh:$mm';
}

String _monthShort(int month) {
  const names = [
    'янв',
    'фев',
    'мар',
    'апр',
    'май',
    'июн',
    'июл',
    'авг',
    'сен',
    'окт',
    'ноя',
    'дек',
  ];
  if (month < 1 || month > 12) return '';
  return names[month - 1];
}
