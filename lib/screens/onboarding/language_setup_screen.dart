import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/providers/city_provider.dart';
import 'package:mobile/providers/locale_provider.dart';
import 'package:provider/provider.dart';

class LanguageSetupScreen extends StatelessWidget {
  const LanguageSetupScreen({super.key});

  void _selectLanguage(BuildContext context, Locale locale) {
    final localeProvider = context.read<LocaleProvider>();
    final cityProvider = context.read<CityProvider>();

    // 1) Сохраняем язык
    localeProvider.setLocale(locale);

    // 2) Смотрим, не пришёл ли redirect из extra (например, из профиля)
    final extra = GoRouterState.of(context).extra;
    String? redirectTo;
    if (extra is Map<String, dynamic>) {
      redirectTo = extra['redirectTo'] as String?;
    }

    if (redirectTo != null) {
      // если открывали выбор языка из профиля — вернём туда
      context.go(redirectTo);
      return;
    }

    // 3) Базовый сценарий онбординга
    if (cityProvider.currentCityId == null) {
      context.go('/onboarding/location');
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final localeProvider = context.watch<LocaleProvider>();
    final currentCode =
        (localeProvider.locale?.languageCode ?? 'ru').toLowerCase();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Выберите язык',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Этот язык будет использоваться в приложении. '
                'Вы сможете изменить его позже в настройках.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 24),

              // RU
              _LanguageTile(
                title: 'Русский',
                subtitle: 'Русский язык интерфейса',
                flagEmoji: '🇷🇺',
                isSelected: currentCode == 'ru',
                onTap: () => _selectLanguage(context, const Locale('ru')),
              ),
              const SizedBox(height: 12),

              // UZ
              _LanguageTile(
                title: 'O‘zbek tili',
                subtitle: 'O‘zbekcha interfeys',
                flagEmoji: '🇺🇿',
                isSelected: currentCode == 'uz',
                onTap: () => _selectLanguage(context, const Locale('uz')),
              ),

              const Spacer(),

              Text(
                'Выбор языка влияет только на интерфейс приложения.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String flagEmoji;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.title,
    required this.subtitle,
    required this.flagEmoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: isSelected
              ? scheme.primary.withOpacity(0.06)
              : scheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                isSelected
                    ? scheme.primary
                    : scheme.outlineVariant.withOpacity(0.7),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Text(
              flagEmoji,
              style: const TextStyle(fontSize: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          theme.textTheme.bodySmall?.color?.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check : Icons.chevron_right,
              color: isSelected ? scheme.primary : scheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}
