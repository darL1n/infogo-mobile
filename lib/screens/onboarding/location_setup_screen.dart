import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/models/city.dart';
import 'package:mobile/providers/category_provider.dart';
import 'package:mobile/providers/city_provider.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

class LocationSetupScreen extends StatefulWidget {
  const LocationSetupScreen({super.key});

  @override
  State<LocationSetupScreen> createState() => _LocationSetupScreenState();
}

class _LocationSetupScreenState extends State<LocationSetupScreen> {
  bool _isDetecting = false;

  @override
  void initState() {
    super.initState();
    // на всякий случай — если кто-то придёт сюда напрямую
    Future.microtask(() async {
      await context.read<CityProvider>().loadCities();
    });
  }

  Future<void> _detectAutomatically() async {
  final cityProvider = context.read<CityProvider>();
  final categoryProvider = context.read<CategoryProvider>();

  setState(() => _isDetecting = true);
  await cityProvider.detectCityByLocation(checkCurrent: false);
  setState(() => _isDetecting = false);

  if (!mounted) return;

  final cityId = cityProvider.currentCityId;

  if (cityId != null) {
    // 👇 чтобы не было "хвоста" от предыдущего города
    categoryProvider.clear();

    await categoryProvider.fetchCategoriesForCity(
      cityId,
      force: true,
    );

    // Город + категории есть → идём на /home
    context.go('/home');
  } else {
    // если не нашли, просто остаёмся на экране, ошибка уже в lastLocationError
  }
}

  void _selectCity(CityModel city) async  {
    final cityProvider = context.read<CityProvider>();
    final categoryProvider = context.read<CategoryProvider>();
    
    cityProvider.setCurrentCity(city.id);
    
    // Сбрасываем старые категории, чтобы не мигал старый город
    categoryProvider.clear();
    
    // Грузим новые категории для выбранного города
    await categoryProvider.fetchCategoriesForCity(
      city.id,
      force: true,
    );
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final cityProvider = context.watch<CityProvider>();
    final cities = cityProvider.cities;
    final errorText = cityProvider.lastLocationError; // 👈 вот оно

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок / приветствие
              Text(
                'Давайте настроим ваш город',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Чтобы показывать места рядом с вами, '
                'нам нужно знать ваш город. '
                'Вы можете разрешить определение по геолокации '
                'или выбрать город из списка.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 24),

              // Кнопка авто-определения
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isDetecting ? null : _detectAutomatically,
                  icon:
                      _isDetecting
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.my_location),
                  label: Text(
                    _isDetecting
                        ? 'Определяем город...'
                        : 'Определить автоматически',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              // 🔻 показываем реальную причину, если есть
              // 🔻 показываем реальную причину, если есть
              if (errorText != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              errorText,
                              style: TextStyle(
                                color: theme.colorScheme.error,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // 👉 Кнопка "Открыть настройки", если ошибка про службы
                      if (errorText.toLowerCase().contains('службы геолокации'))
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            Geolocator.openLocationSettings();
                          },
                          child: const Text(
                            'Открыть настройки геолокации',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),
              Divider(color: Colors.grey.shade300),
              const SizedBox(height: 8),

              Text(
                'Или выберите город вручную',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              // Список городов
              if (cities.isEmpty)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: cities.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final city = cities[index];
                      final isCurrent =
                          cityProvider.currentCityId != null &&
                          city.id == cityProvider.currentCityId;

                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        tileColor:
                            isCurrent
                                ? scheme.primary.withOpacity(0.06)
                                : scheme.surface,
                        leading: Icon(
                          Icons.location_city,
                          color:
                              isCurrent
                                  ? scheme.primary
                                  : theme.iconTheme.color,
                        ),
                        title: Text(
                          city.name,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight:
                                isCurrent ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                        trailing:
                            isCurrent
                                ? Icon(Icons.check, color: scheme.primary)
                                : const Icon(Icons.chevron_right),
                        onTap: () => _selectCity(city),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
