import 'package:flutter/material.dart';

class GreetingSection extends StatelessWidget {
  final String? phone;
  final String? cityName;

  const GreetingSection({super.key, this.phone, this.cityName});

  String _greetingByTime() {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'Доброй ночи';
    if (hour < 12) return 'Доброе утро';
    if (hour < 18) return 'Добрый день';
    return 'Добрый вечер';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final greeting = _greetingByTime();
    final namePart = phone ?? 'гость';
    final cityPart = cityName ?? 'вашем городе';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting, $namePart 👋',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Сегодня в $cityPart — давай выберем, куда сходить?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
