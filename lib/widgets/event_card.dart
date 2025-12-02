

import 'package:flutter/material.dart';

/// Общая модель события
class EventCardData {
  final DateTime date;      // для фильтрации
  final String dateLabel;   // красивый текст "Сегодня, 19:00"
  final String title;
  final String place;
  final String tag;         // тип / категория события

  EventCardData({
    required this.date,
    required this.dateLabel,
    required this.title,
    required this.place,
    required this.tag,
  });
}

/// Общая карточка события (юзаем и на главной, и на /events)
class EventCard extends StatelessWidget {
  final EventCardData data;
  final ColorScheme scheme;
  final ThemeData theme;

  const EventCard({
    super.key,
    required this.data,
    required this.scheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // TODO: переход на детальную страницу события
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                scheme.primary.withOpacity(0.12),
                scheme.primary.withOpacity(0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.black.withOpacity(0.04),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 строка "дата + категория"
              Row(
                children: [
                  Icon(
                    Icons.event,
                    size: 14,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: 4),

                  // вся правая часть — в Expanded
                  Expanded(
                    child: Row(
                      children: [
                        // Дата — всегда целиком, без обрезки
                        Text(
                          data.dateLabel,
                          softWrap: false,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: theme.textTheme.bodySmall?.color
                                ?.withOpacity(0.85),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Категория — забирает остаток, при нехватке режем её
                        Flexible(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              constraints: const BoxConstraints(
                                maxWidth: 130,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                data.tag,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: scheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // 🔹 название события — одна строка + ellipsis
              Text(
                data.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 4),

              // 🔹 место проведения
              Row(
                children: [
                  Icon(
                    Icons.place_outlined,
                    size: 16,
                    color: scheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      data.place,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.outline,
                      ),
                    ),
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

class EventsSkeleton extends StatelessWidget {
  final String cityLabel;

  const EventsSkeleton({super.key, required this.cityLabel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Афиша $cityLabel',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // маленький "скелет" вместо кнопки "Все события"
              Container(
                width: 80,
                height: 16,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 4),

        SizedBox(
          height: 120,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return const _EventCardSkeleton();
            },
          ),
        ),
      ],
    );
  }
}

class _EventCardSkeleton extends StatelessWidget {
  const _EventCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 260,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.black.withOpacity(0.04),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // первая строка (дата + бейдж)
          Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 60,
                height: 16,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // заголовок
          Container(
            height: 12,
            width: 180,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 12,
            width: 120,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.9),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const Spacer(),
          // место
          Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


String formatDateLabel(DateTime startAt, bool isAllDay) {
  final local = startAt.toLocal();
  final now = DateTime.now();

  final today = DateTime(now.year, now.month, now.day);
  final dateOnly = DateTime(local.year, local.month, local.day);
  final diff = dateOnly.difference(today).inDays;

  String dayPart;
  if (diff == 0) {
    dayPart = 'Сегодня';
  } else if (diff == 1) {
    dayPart = 'Завтра';
  } else {
    final weekday = _weekdayShort(dateOnly.weekday);
    final month = _monthShort(dateOnly.month);
    dayPart = '$weekday, ${dateOnly.day} $month';
  }

  if (isAllDay) {
    return '$dayPart, весь день';
  }

  final time = TimeOfDay.fromDateTime(local);
  final hh = time.hour.toString().padLeft(2, '0');
  final mm = time.minute.toString().padLeft(2, '0');

  return '$dayPart, $hh:$mm';
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
