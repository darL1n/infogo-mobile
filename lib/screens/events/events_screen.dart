// events_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:mobile/widgets/event_card.dart';      // EventCard + formatDateLabel
import 'package:mobile/providers/city_provider.dart';
import 'package:mobile/providers/event_provider.dart';
import 'package:mobile/widgets/base_layout.dart';
import 'package:mobile/widgets/custom_pull_to_refresh.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  static const int _daysVisible = 7;

  late DateTime _stripStart;   // от какой даты рисуем ленту
  late DateTime _selectedDay;  // выбранный день
  String? _selectedTag;        // null = все категории

  // bool _initialized = false;

   @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    _stripStart = DateTime(now.year, now.month, now.day);
    _selectedDay = _stripStart;

    // 👇 безопасно дергаем провайдер уже после первого кадра
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cityId = context.read<CityProvider>().currentCityId;
      if (cityId != null) {
        context.read<EventProvider>().initForCity(cityId);
      }
    });
  }



  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<EventCardData> _filtered(List<EventCardData> all) {
    return all.where((e) {
      final byDay = _isSameDay(e.date, _selectedDay);
      final byTag = _selectedTag == null || e.tag == _selectedTag;
      return byDay && byTag;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final city = context.watch<CityProvider>().currentCity;
    final cityName = city?.name ?? 'городе';

    final evProv = context.watch<EventProvider>();

    // конвертируем EventModel → EventCardData
    final allEvents = evProv.events.map((e) {
      return EventCardData(
        date: e.startAt,
        dateLabel: formatDateLabel(e.startAt, e.isAllDay),
        title: e.title,
        place: e.placeName ?? 'Место уточняется',
        tag: e.categoryName ?? 'Событие',
      );
    }).toList();

    final events = _filtered(allEvents);

    final content = CustomPullToRefresh(
      onRefresh: () => context.read<EventProvider>().refresh(),
      slivers: [
        // Лента дат
        SliverToBoxAdapter(
          child: _buildDateStrip(context, theme, scheme, allEvents),
        ),

        // Фильтры по тегам / категориям
        SliverToBoxAdapter(
          child: _buildTagFilters(theme, scheme, allEvents),
        ),

        // Состояния загрузки / пусто / список
        if (evProv.isLoading && allEvents.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 32),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          )
        else if (events.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: scheme.outlineVariant.withOpacity(0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.event_busy,
                      color: scheme.outline,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'На выбранную дату пока нет событий. '
                        'Попробуй другой день или категорию.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.outline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          SliverList.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final e = events[index];
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: EventCard(
                  data: e,
                  scheme: scheme,
                  theme: theme,
                ),
              );
            },
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );

    return BaseLayout(
      title: 'Все события',
      currentIndex: 0,
      showBackButton: true,
      fallbackRoute: '/home',
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

  // ---------- UI: лента дат ----------

  Widget _buildDateStrip(
    BuildContext context,
    ThemeData theme,
    ColorScheme scheme,
    List<EventCardData> all,
  ) {
    final days = List.generate(
      _daysVisible,
      (i) => _stripStart.add(Duration(days: i)),
    );

    final monthNameRaw = DateFormat.MMMM('ru').format(days.first);
    final monthName =
        monthNameRaw[0].toUpperCase() + monthNameRaw.substring(1);

    int eventsCountForDay(DateTime d) =>
        all.where((e) => _isSameDay(e.date, d)).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // заголовок месяца + иконка календаря
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
          child: Row(
            children: [
              Text(
                monthName,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.outline,
                  letterSpacing: 0.4,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.calendar_today, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDay,
                    firstDate:
                        DateTime.now().subtract(const Duration(days: 365)),
                    lastDate:
                        DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDay =
                          DateTime(picked.year, picked.month, picked.day);
                      _stripStart = _selectedDay;
                    });
                  }
                },
              ),
            ],
          ),
        ),

        SizedBox(
          height: 74,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final date = days[index];
              final isSelected = _isSameDay(date, _selectedDay);
              final isWeekend = date.weekday == DateTime.saturday ||
                  date.weekday == DateTime.sunday;
              final hasEvents = eventsCountForDay(date) > 0;

              final baseTextColor = isWeekend
                  ? Colors.red.shade400
                  : theme.textTheme.bodyMedium?.color ?? Colors.black;

              final bgColor = isSelected
                  ? scheme.primary.withOpacity(0.10)
                  : scheme.surface;
              final borderColor = isSelected
                  ? scheme.primary
                  : scheme.outlineVariant.withOpacity(0.6);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDay = date;
                  });
                },
                child: Container(
                  width: 56,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _weekdayShortRu(date.weekday),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? scheme.primary : baseTextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date.day.toString(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isSelected ? scheme.primary : baseTextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (hasEvents)
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _weekdayShortRu(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'ПН';
      case DateTime.tuesday:
        return 'ВТ';
      case DateTime.wednesday:
        return 'СР';
      case DateTime.thursday:
        return 'ЧТ';
      case DateTime.friday:
        return 'ПТ';
      case DateTime.saturday:
        return 'СБ';
      case DateTime.sunday:
      default:
        return 'ВС';
    }
  }

  // ---------- UI: фильтры по тегам ----------

  Widget _buildTagFilters(
    ThemeData theme,
    ColorScheme scheme,
    List<EventCardData> all,
  ) {
    // уникальные теги из событий
    final tags = {
      for (final e in all) e.tag,
    }.toList()
      ..sort();

    if (tags.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _TagChip(
              label: 'Все категории',
              isActive: _selectedTag == null,
              onTap: () {
                setState(() => _selectedTag = null);
              },
            ),
            const SizedBox(width: 8),
            ...tags.map((tag) {
              final active = _selectedTag == tag;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _TagChip(
                  label: tag,
                  isActive: active,
                  onTap: () {
                    setState(() => _selectedTag = active ? null : tag);
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TagChip({
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
          color: isActive
              ? scheme.primary.withOpacity(0.12)
              : scheme.surfaceVariant.withOpacity(0.4),
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
