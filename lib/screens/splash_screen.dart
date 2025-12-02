import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:mobile/providers/city_provider.dart';
import 'package:mobile/providers/locale_provider.dart';
import 'package:mobile/providers/category_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _cardOpacity;
  late final Animation<double> _progressWidth;

  @override
  void initState() {
    super.initState();

    // 🔹 Анимации
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _cardOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.8, curve: Curves.easeIn),
      ),
    );

    _progressWidth = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // 🔹 запускаем твою логику инициализации
    // (отдельный async — UI не блокируется)
    _init();
  }

  Future<void> _init() async {
    // чуть показать логотип / анимацию
    await Future.delayed(const Duration(milliseconds: 5000));

    // 1) язык
    final localeProvider = context.read<LocaleProvider>();
    final hasLocale = localeProvider.hasLocale;

    if (!hasLocale) {
      if (!mounted) return;
      context.go('/onboarding/language');
      return;
    }

    // 2) город + категории
    final cityProvider = context.read<CityProvider>();
    final categoryProvider = context.read<CategoryProvider>();

    // загружаем города и текущий cityId из Hive/API
    await cityProvider.loadCities();
    final cityId = cityProvider.currentCityId;

    if (!mounted) return;

    if (cityId == null) {
      // города ещё нет → экран выбора города
      context.go('/onboarding/location');
    } else {
      // город уже есть → подтянем дерево категорий для этого города
      await categoryProvider.fetchCategoriesForCity(
        cityId,
        force: false, // без жёсткого форса, если уже будут в кеше
      );

      if (!mounted) return;
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final city = context.watch<CityProvider>().currentCity;

    return Scaffold(
      body: Stack(
        children: [
          // 💫 Фон с градиентом
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primaryContainer.withOpacity(0.9),
                ],
              ),
            ),
          ),

          // мягкие "блики"
          Positioned(
            top: -80,
            right: -40,
            child: _BlurCircle(size: 180, opacity: 0.25),
          ),
          Positioned(
            bottom: -60,
            left: -30,
            child: _BlurCircle(size: 160, opacity: 0.18),
          ),

          // Основной контент
          SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Логотип + название
                  ScaleTransition(
                    scale: _logoScale,
                    child: FadeTransition(
                      opacity: _logoOpacity,
                      child: Column(
                        children: [
                          // 👉 тут можно поставить твой asset-логотип
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Image.asset(
                                'assets/infogo_logo.png',
                                width: 70,
                                height: 70,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'InfoGo',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Местный гид по городу',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // "Карточка города"
                  FadeTransition(
                    opacity: _cardOpacity,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.98),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(
                                0.08,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.location_on_outlined,
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  city?.name ?? 'Определяем город...',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  city == null
                                      ? 'Загружаем настройки и справочник'
                                      : 'Загружаем места и события',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Нижняя прогресс-полоска
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              left: false,
              right: false,
              // bottom: true по умолчанию
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 32,
                  right: 32,
                  bottom: 24, // твой дизайнерский отступ над системной панелью
                ),
                child: AnimatedBuilder(
                  animation: _progressWidth,
                  builder: (context, _) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                        ),
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: _progressWidth.value,
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlurCircle extends StatelessWidget {
  final double size;
  final double opacity;

  const _BlurCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }
}
