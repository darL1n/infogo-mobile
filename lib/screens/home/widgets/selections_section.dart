// selections_section.dart
import 'dart:async';
import 'package:flutter/material.dart';

class SelectionsSection extends StatefulWidget {
  final String? cityName;

  const SelectionsSection({super.key, this.cityName});

  @override
  State<SelectionsSection> createState() => _SelectionsSectionState();
}

class _SelectionsSectionState extends State<SelectionsSection> {
  late final PageController _controller;
  int _currentPage = 0;
  Timer? _timer;

  static const int _itemsCount = 3;

  @override
  void initState() {
    super.initState();
    _controller = PageController();

    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return timer.cancel();
      final nextPage = (_currentPage + 1) % _itemsCount;
      _controller.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    final cityLabel = widget.cityName ?? 'вашем городе';

    final List<_SelectionCardData> cards = [
      _SelectionCardData(
        icon: Icons.star,
        title: 'Лучшее в $cityLabel',
        subtitle: 'Самые высокие оценки',
      ),
      _SelectionCardData(
        icon: Icons.nightlight_round,
        title: 'Вечерние прогулки',
        subtitle: 'Красивые виды и огни',
      ),
      _SelectionCardData(
        icon: Icons.local_offer,
        title: 'Скидки и акции',
        subtitle: 'Выгодные предложения рядом',
      ),
    ];

    final gradients = [
      [
        scheme.primary.withValues(alpha: 0.18),
        scheme.primary.withValues(alpha: 0.05),
      ],
      [
        scheme.secondary.withValues(alpha: 0.18),
        scheme.secondary.withValues(alpha: 0.05),
      ],
      [
        scheme.tertiary.withValues(alpha: 0.18),
        scheme.tertiary.withValues(alpha: 0.05),
      ],
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'Подборки для тебя',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            height: 140,
            child: PageView.builder(
              controller: _controller,
              physics: const PageScrollPhysics(),
              itemCount: cards.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                final data = cards[index];
                final gradient = gradients[index % gradients.length];

                return Center(
                  child: SizedBox(
                    width: screenWidth - 32,
                    child: _SelectionCard(
                      data: data,
                      gradient: gradient,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(cards.length, (index) {
              final isActive = index == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 10 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive
                      ? scheme.primary
                      : scheme.outlineVariant.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _SelectionCardData {
  final IconData icon;
  final String title;
  final String subtitle;

  _SelectionCardData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class _SelectionCard extends StatelessWidget {
  final _SelectionCardData data;
  final List<Color> gradient;

  const _SelectionCard({
    super.key,
    required this.data,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white.withValues(alpha: 0.9),
            child: Icon(
              data.icon,
              size: 18,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            data.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
