// lib/screens/place/widgets/place_sections_widget.dart

import 'package:flutter/material.dart';
import 'package:mobile/models/place_detail.dart';

class PlaceSectionsWidget extends StatelessWidget {
  final List<PlaceSection> sections;

  const PlaceSectionsWidget({super.key, required this.sections});

  @override
  Widget build(BuildContext context) {
    final active = sections
        .where((s) => s.isActive)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    if (active.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, 
        children: active
            .map((section) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _SectionCard(section: section),
                ))
            .toList(),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final PlaceSection section;

  const _SectionCard({required this.section});

  @override
  Widget build(BuildContext context) {
    switch (section.type) {
      case 'features':
        return _FeaturesSectionCard(section: section);
      case 'price_list':
        return _PriceListSectionCard(section: section);
      case 'info':
        return _InfoSectionCard(section: section);
      case 'rules':
        return _RulesSectionCard(section: section);
      case 'faq':
        return _FaqSectionCard(section: section);
      case 'promo':
        return _PromoSectionCard(section: section);
      default:
        // на всякий случай fallback
        return _InfoSectionCard(section: section);
    }
  }
}


class _FeaturesSectionCard extends StatelessWidget {
  final PlaceSection section;

  const _FeaturesSectionCard({required this.section});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final items = (section.payload['items'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();

    if (items.isEmpty) return const SizedBox.shrink();

    final title = section.title.isNotEmpty
        ? section.title
        : 'Что есть на месте';

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((raw) {
              final label = raw['label'] as String? ?? '';
              final value = raw['value'] as String?;
              // пока игнорируем raw['icon'], можно потом замапить parking/wifi/etc → иконки

              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: scheme.outlineVariant.withOpacity(0.6),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: scheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (value != null && value.isNotEmpty)
                          Text(
                            value,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withOpacity(0.75),
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}


class _PriceListSectionCard extends StatelessWidget {
  final PlaceSection section;

  const _PriceListSectionCard({required this.section});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final payload = section.payload;
    final currency = (payload['currency'] as String?) ?? 'UZS';

    final groups = (payload['groups'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();

    if (groups.isEmpty) return const SizedBox.shrink();

    final title = section.title.isNotEmpty
        ? section.title
        : 'Цены';

    String formatPrice(num? price) {
      if (price == null) return '';
      // простенький формат: 55 000 UZS
      final str = price.toInt().toString();
      final withSpaces = str.replaceAllMapped(
        RegExp(r'(?=(\d{3})+(?!\d))'),
        (m) => ' ',
      );
      return '$withSpaces $currency';
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...groups.map((group) {
            final groupName = group['name'] as String?;
            final items = (group['items'] as List<dynamic>? ?? [])
                .whereType<Map<String, dynamic>>()
                .toList();

            if (items.isEmpty) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (groupName != null && groupName.isNotEmpty) ...[
                    Text(
                      groupName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  ...items.map((item) {
                    final name = item['name'] as String? ?? '';
                    final price = item['price'] as num?;
                    final description = item['description'] as String?;
                    final priceStr = formatPrice(price);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                              if (priceStr.isNotEmpty)
                                Text(
                                  priceStr,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: scheme.primary,
                                  ),
                                ),
                            ],
                          ),
                          if (description != null &&
                              description.trim().isNotEmpty)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                description,
                                style:
                                    theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color
                                      ?.withOpacity(0.75),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}


class _InfoSectionCard extends StatelessWidget {
  final PlaceSection section;

  const _InfoSectionCard({required this.section});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final items = (section.payload['items'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();

    if (items.isEmpty && section.title.isEmpty) {
      return const SizedBox.shrink();
    }

    final title = section.title.isNotEmpty
        ? section.title
        : 'Информация';

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            Text(
              section.payload['body'] as String? ?? '',
              style: theme.textTheme.bodyMedium,
            )
          else
            ...items.map((it) {
              final t = it['title'] as String?;
              final body = it['body'] as String? ?? '';
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (t != null && t.isNotEmpty)
                      Text(
                        t,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (body.isNotEmpty)
                      Text(
                        body,
                        style: theme.textTheme.bodyMedium,
                      ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}


class _RulesSectionCard extends StatelessWidget {
  final PlaceSection section;

  const _RulesSectionCard({required this.section});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final items = (section.payload['items'] as List<dynamic>? ?? [])
        .whereType<String>()
        .toList();

    if (items.isEmpty) return const SizedBox.shrink();

    final title = section.title.isNotEmpty
        ? section.title
        : 'Правила и ограничения';

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          ...items.map(
            (rule) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• '),
                  Expanded(
                    child: Text(
                      rule,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}



class _FaqSectionCard extends StatelessWidget {
  final PlaceSection section;

  const _FaqSectionCard({required this.section});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final items = (section.payload['items'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();

    if (items.isEmpty) return const SizedBox.shrink();

    final title = section.title.isNotEmpty ? section.title : 'FAQ';

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map((it) {
            final q = it['question'] as String? ?? '';
            final a = it['answer'] as String? ?? '';
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    q,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (a.isNotEmpty)
                    Text(
                      a,
                      style: theme.textTheme.bodyMedium,
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}


class _PromoSectionCard extends StatelessWidget {
  final PlaceSection section;

  const _PromoSectionCard({required this.section});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final items = (section.payload['items'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();

    if (items.isEmpty) return const SizedBox.shrink();

    final title = section.title.isNotEmpty ? section.title : 'Акции';

    return Container(
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scheme.primary.withOpacity(0.2),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map((it) {
            final t = it['title'] as String? ?? '';
            final description = it['description'] as String? ?? '';
            final validUntil = it['valid_until'] as String?;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (t.isNotEmpty)
                    Text(
                      t,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (description.isNotEmpty)
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium,
                    ),
                  if (validUntil != null && validUntil.isNotEmpty)
                    Text(
                      'До $validUntil',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color
                            ?.withOpacity(0.75),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
