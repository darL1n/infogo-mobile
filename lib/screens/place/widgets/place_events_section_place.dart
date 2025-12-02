// place_events_section_place.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/models/place_detail.dart';
import 'package:mobile/widgets/event_card.dart';

class PlaceEventsSectionForPlace extends StatelessWidget {
  final PlaceDetailModel place;

  const PlaceEventsSectionForPlace({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final events = place.upcomingEvents
        .map(
          (e) => EventCardData(
            date: e.startAt,
            dateLabel: _buildDateLabel(e.startAt),
            title: e.title,
            place: place.name,
            tag: e.isFree ? 'Бесплатно' : 'Событие',
          ),
        )
        .toList();

    if (events.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок + "Все события"
          Row(
            children: [
              Expanded(
                child: Text(
                  'События в этом месте',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  context.push(
                    '/events',
                    extra: {'placeId': place.id},
                  );
                },
                child: const Text('Все'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Column(
            children: events
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: EventCard(
                      data: e,
                      scheme: scheme,
                      theme: theme,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  String _buildDateLabel(DateTime date) {
    final now = DateTime.now();
    final isToday = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
    final isTomorrow = date.year == now.year &&
        date.month == now.month &&
        date.day == now.add(const Duration(days: 1)).day;

    final time =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    if (isToday) return 'Сегодня, $time';
    if (isTomorrow) return 'Завтра, $time';
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}, $time';
  }
}
