// events_section.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/providers/city_provider.dart';
import 'package:mobile/providers/event_provider.dart';
import 'package:mobile/widgets/event_card.dart';
import 'package:provider/provider.dart';

class EventsSection extends StatefulWidget {
  final String? cityName;

  const EventsSection({super.key, this.cityName});

  @override
  State<EventsSection> createState() => _EventsSectionState();
}

class _EventsSectionState extends State<EventsSection> {
  bool _requested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_requested) return;

    final cityId = context.read<CityProvider>().currentCityId;
    if (cityId == null) return; // город ещё не выбран

    _requested = true;

    // 🔹 запускаем загрузку ПОСЛЕ текущего кадра
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final eventProv = context.read<EventProvider>();

      if (eventProv.homeFeatured.isEmpty) {
        eventProv.loadHomeFeatured(cityId);
      }
    });
  }

    @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final cityLabel = widget.cityName ?? 'вашем городе';

    return Consumer<EventProvider>(
      builder: (context, evProv, _) {
        final events = evProv.homeFeatured;
        final loading = evProv.homeLoading;

        // пока вообще ничего не знаем и идёт первая загрузка
        if (loading && events.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: EventsSkeleton(cityLabel: cityLabel),
          );
        }

        // загрузка завершилась, но событий нет
        if (!loading && events.isEmpty) {
          return const SizedBox.shrink(); // или аккуратный empty-state
        }

        // есть события (и не важно, грузимся мы сейчас или нет)
        final cards = events.map((e) {
          return EventCardData(
            date: e.startAt,
            dateLabel: formatDateLabel(e.startAt, e.isAllDay),
            title: e.title,
            place: e.placeName ?? 'Место уточняется',
            tag: e.categoryName ?? 'Событие',
          );
        }).toList();

        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // заголовок + "Все события"
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
                    TextButton(
                      onPressed: () => context.push('/events'),
                      child: const Text('Все события'),
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: 120,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                  scrollDirection: Axis.horizontal,
                  itemCount: cards.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final data = cards[index];
                    return SizedBox(
                      width: 260,
                      child: EventCard(
                        data: data,
                        scheme: scheme,
                        theme: theme,
                      ),
                    );
                  },
                ),
              ),

              if (loading && events.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.only(left: 16, bottom: 4),
                  child: SizedBox(
                    height: 16,
                    width: 16,
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

