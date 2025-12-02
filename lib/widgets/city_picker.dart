import 'package:flutter/material.dart';
import 'package:mobile/utils/on_city_selected.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile/models/city.dart';
import 'package:mobile/providers/city_provider.dart';

Future<void> showCityPickerSheet(BuildContext context) async {
  final cityProvider = context.read<CityProvider>();

  // если ещё не загружали — подтянем города
  if (!cityProvider.isLoaded && cityProvider.cities.isEmpty) {
    await cityProvider.loadCities();
  }

  await showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    isScrollControlled: true,
    builder: (ctx) {
      return const _CityPickerSheet();
    },
  );
}

class _CityPickerSheet extends StatelessWidget {
  const _CityPickerSheet();



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Consumer<CityProvider>(
          builder: (ctx, cityProv, _) {
            final cities = cityProv.cities;
            final currentId = cityProv.currentCityId;

            if (cities.isEmpty) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            // Простая логика "популярных": первые 4 города
            final List<CityModel> popular = cities.take(0).toList();
            final List<CityModel> others = cities
                .where((c) => !popular.any((p) => p.id == c.id))
                .toList();

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                // маленький "хэндл"
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 12),

                // заголовок + кнопка "Все города"
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        'Ваш город',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // закрываем шит
                          context.push('/cities'); // страница со списком + поиском
                        },
                        child: const Text('Все города'),
                      ),
                    ],
                  ),
                ),

                // --- Определить по местоположению ---
                ListTile(
                  leading: cityProv.isDetectingLocation
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location_outlined),
                  title: const Text('Определить по местоположению'),
                  subtitle: cityProv.lastLocationError != null
                      ? Text(
                          cityProv.lastLocationError!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        )
                      : null,
                  onTap: cityProv.isDetectingLocation
                      ? null
                      : () async {
                          await cityProv.detectCityByLocation(
                            checkCurrent: false,
                          );

                          final detected = cityProv.currentCity;
                          final error = cityProv.lastLocationError;

                          if (detected != null) {
                            onCitySelected(ctx, detected);
                            if (ctx.mounted) {
                              Navigator.of(ctx).pop();
                            }
                          }

                          if (error != null && ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(content: Text(error)),
                            );
                          }
                        },
                ),

                const Divider(height: 1),

                // --- Популярные города ---
                if (popular.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Популярные города',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color
                              ?.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: popular.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (ctx, index) {
                        final city = popular[index];
                        final selected = city.id == currentId;

                        return ChoiceChip(
                          label: Text(city.name),
                          selected: selected,
                          onSelected: (_) {
                            onCitySelected(ctx, city);
                            Navigator.of(ctx).pop();
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                ],

                // --- Все города ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Все города',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color
                            ?.withOpacity(0.8),
                      ),
                    ),
                  ),
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.45,
                  child: ListView.builder(
                    itemCount: others.length,
                    itemBuilder: (ctx, index) {
                      final city = others[index];
                      final bool isCurrent = city.id == currentId;

                      return ListTile(
                        leading: const Icon(Icons.location_city_outlined),
                        title: Text(city.name),
                        trailing: isCurrent
                            ? Icon(
                                Icons.check_circle,
                                color: theme.colorScheme.primary,
                              )
                            : null,
                        onTap: () {
                          onCitySelected(ctx, city);
                          Navigator.of(ctx).pop();
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
