// home_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/providers/city_provider.dart';
import 'package:mobile/providers/event_provider.dart';
import 'package:mobile/providers/news_provider.dart';
import 'package:mobile/providers/user_provider.dart';
import 'package:mobile/providers/category_provider.dart';
import 'package:mobile/screens/home/widgets/category_section.dart';
import 'package:mobile/screens/home/widgets/map_preview.dart';
import 'package:mobile/screens/home/widgets/selections_section.dart';
import 'package:mobile/screens/home/widgets/events_section.dart';
import 'package:mobile/screens/home/widgets/news_section.dart';
import 'package:mobile/widgets/base_layout.dart';
import 'package:mobile/widgets/city_picker.dart';
import 'package:mobile/widgets/custom_pull_to_refresh.dart';
import 'package:provider/provider.dart';

import 'widgets/home_app_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final city = context.watch<CityProvider>().currentCity;
    final categories = context.watch<CategoryProvider>().categories;

    final content = CustomPullToRefresh(
      onRefresh: () => _handleRefresh(context),
      slivers: [
        // 🔹 Hero-приветствие
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: _HeroBlock(phone: user?.phone, cityName: city?.name),
          ),
        ),

        // 🔹 Афиша / события города
        SliverToBoxAdapter(child: EventsSection(cityName: city?.name)),

        // 🔹 Новости города
        SliverToBoxAdapter(child: NewsSection(cityName: city?.name)),

        // 🔹 Персональные подборки
        SliverToBoxAdapter(child: SelectionsSection(cityName: city?.name)),

        // 🔹 Быстрые категории
        SliverToBoxAdapter(child: CategorySection(categories: categories)),

        // // 🔹 Превью карты
        // const SliverToBoxAdapter(
        //   child: MapPreviewWidget(),
        // ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );

    return BaseLayout(
      title: 'Главная',
      currentIndex: 0,
      appBar: HomeAppBar(
        onSearchTap: () => context.push('/search', extra: {'useLayout': false}),
        onCityTap: () {
          showCityPickerSheet(context);
        },
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        // Просто регистрируем горизонтальный жест, но ничего не делаем.
        // Это достаточно, чтобы VerticalDrag внутри ScrollView
        // не «выиграл» жест и не начал вертикальный скролл.
        onHorizontalDragStart: (_) {},
        onHorizontalDragUpdate: (_) {},
        onHorizontalDragEnd: (_) {},
        child: content,
      ),
    );
  }

  Future<void> _handleRefresh(BuildContext context) async {
    debugPrint('REFRESH');
    // сюда потом добавим:
    // - обновление событий
    // - обновление новостей
    // - обновление категорий

    final cityId = context.read<CityProvider>().currentCityId;

    // категории, новости, селекшены — позже
    if (cityId != null) {
      await context.read<EventProvider>().loadHomeFeatured(cityId);
      await context.read<NewsProvider>().loadHomeFeatured(cityId);
    }
  }
}

class _HeroBlock extends StatelessWidget {
  final String? phone;
  final String? cityName; // пока не используем, оставил для совместимости

  /// Пока заглушки — позже сюда можно пробрасывать реальные данные
  final int? temperature; // например: 23
  final String? weatherDescription; // например: "Солнечно"
  final IconData? weatherIcon; // например: Icons.wb_sunny_rounded

  const _HeroBlock({
    this.phone,
    this.cityName,
    this.temperature,
    this.weatherDescription,
    this.weatherIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final greetingName = phone ?? 'гость';

    final now = DateTime.now();
    final dateLabel = _formatDate(now); // "Пн, 1 дек"
    final timeLabel = _formatTime(now); // "12:34"

    final tempLabel = temperature != null ? '${temperature!.round()}°' : '--°';
    final descLabel = weatherDescription ?? 'Хороший день, чтобы прогуляться';

    final icon = weatherIcon ?? Icons.wb_sunny_rounded;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary.withValues(alpha: 0.14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── «виджет» с датой / временем / погодой ───────────────
          // Row(
          //   children: [
          //     // левая колонка: сегодня + время + подпись
          //     Expanded(
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           Text(
          //             'Сегодня, $dateLabel',
          //             style: theme.textTheme.bodySmall?.copyWith(
          //               fontWeight: FontWeight.w600,
          //               color: scheme.onSurface.withValues(alpha: 0.8),
          //             ),
          //           ),
          //           const SizedBox(height: 2),
          //           Text(
          //             timeLabel,
          //             style: theme.textTheme.titleLarge?.copyWith(
          //               fontWeight: FontWeight.w700,
          //             ),
          //           ),
          //           const SizedBox(height: 4),
          //           Text(
          //             descLabel,
          //             maxLines: 2,
          //             overflow: TextOverflow.ellipsis,
          //             style: theme.textTheme.bodySmall?.copyWith(
          //               color: theme.textTheme.bodySmall?.color
          //                   ?.withValues(alpha: 0.8),
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),

          //     const SizedBox(width: 12),

          //     // правая часть: кругленький «чип» с температурой
          //     Container(
          //       padding: const EdgeInsets.symmetric(
          //         horizontal: 10,
          //         vertical: 8,
          //       ),
          //       decoration: BoxDecoration(
          //         color: Colors.white.withValues(alpha: 0.95),
          //         borderRadius: BorderRadius.circular(999),
          //         boxShadow: [
          //           BoxShadow(
          //             color: Colors.black.withValues(alpha: 0.08),
          //             blurRadius: 10,
          //             offset: const Offset(0, 4),
          //           ),
          //         ],
          //       ),
          //       child: Row(
          //         mainAxisSize: MainAxisSize.min,
          //         children: [
          //           Icon(
          //             icon,
          //             size: 20,
          //             color: scheme.primary,
          //           ),
          //           const SizedBox(width: 6),
          //           Text(
          //             tempLabel,
          //             style: theme.textTheme.titleMedium?.copyWith(
          //               fontWeight: FontWeight.w700,
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ],
          // ),

          // const SizedBox(height: 16),

          // приветствие
          Text(
            'Добро пожаловать, $greetingName 👋',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Собрали афишу, новости и подборки — всё, чтобы не скучать рядом с вами.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.85),
            ),
          ),

          const SizedBox(height: 16),

          // CTA "Смотреть на карте"
          const _MapHeroCta(),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final weekday = _weekdayShort(dt.weekday);
    final month = _monthShort(dt.month);
    return '$weekday, ${dt.day} $month';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _weekdayShort(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Пн';
      case DateTime.tuesday:
        return 'Вт';
      case DateTime.wednesday:
        return 'Ср';
      case DateTime.thursday:
        return 'Чт';
      case DateTime.friday:
        return 'Пт';
      case DateTime.saturday:
        return 'Сб';
      case DateTime.sunday:
      default:
        return 'Вс';
    }
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
}

class _MapHeroCta extends StatelessWidget {
  const _MapHeroCta({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: Colors.white.withValues(alpha: 0.96),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/map', extra: {'rootCategories': true}),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primary.withValues(alpha: 0.12),
                ),
                child: Icon(
                  Icons.map_outlined,
                  color: colors.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Смотреть на карте',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Показать места поблизости и маршруты на карте.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: colors.onSurface.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
