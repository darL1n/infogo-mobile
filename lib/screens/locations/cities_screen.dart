import 'package:flutter/material.dart';
import 'package:mobile/utils/on_city_selected.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/models/city.dart';
import 'package:mobile/providers/city_provider.dart';
import 'package:mobile/widgets/base_layout.dart';

class CitiesScreen extends StatefulWidget {
  const CitiesScreen({super.key});

  @override
  State<CitiesScreen> createState() => _CitiesScreenState();
}

class _CitiesScreenState extends State<CitiesScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    final cityProvider = context.read<CityProvider>();

    // если города ещё не загружены – подгружаем
    if (cityProvider.cities.isEmpty) {
      cityProvider.loadCities();
    }

    _searchCtrl.addListener(() {
      setState(() {
        _query = _searchCtrl.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CityProvider>(
      builder: (context, cityProvider, child) {
        final theme = Theme.of(context);

        final allCities = cityProvider.cities;

        List<CityModel> filtered = allCities;
        if (_query.isNotEmpty) {
          filtered =
              allCities
                  .where(
                    (c) => c.name.toLowerCase().contains(_query.toLowerCase()),
                  )
                  .toList();
        }

        Widget body;
        if (allCities.isEmpty) {
          body = const Center(child: CircularProgressIndicator());
        } else if (filtered.isEmpty) {
          body = const Center(child: Text('Города не найдены'));
        } else {
          final currentId = cityProvider.currentCityId;

          body = ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (context, index) {
              final city = filtered[index];
              final selected = city.id == currentId;

              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tileColor: theme.cardColor,
                title: Text(city.name),
                trailing:
                    selected
                        ? Icon(
                          Icons.check_circle,
                          color: theme.colorScheme.primary,
                        )
                        : null,
                onTap: () {
                  onCitySelected(context, city);

                  context.pop(); // возвращаемся в каталог
                },
              );
            },
          );
        }

        return BaseLayout(
          title: 'Выбор города',
          currentIndex: 1, // та же вкладка, что и каталог
          showBackButton: true,
          onBackPressed: () => context.pop(),
          child: Column(
            children: [
              // поле поиска
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Поиск города',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Expanded(child: body),
            ],
          ),
        );
      },
    );
  }
}
