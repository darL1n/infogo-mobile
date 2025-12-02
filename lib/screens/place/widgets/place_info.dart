// place_info.dart

import 'package:flutter/material.dart';
import 'package:mobile/models/place_detail.dart';
import 'package:mobile/utils/url_helper.dart';

class PlaceInfoWidget extends StatelessWidget {
  final PlaceDetailModel place;

  const PlaceInfoWidget({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Название + рейтинг
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${place.category.name} • ${place.city.name}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodySmall?.color
                              ?.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _RatingChip(place: place),
              ],
            ),

            const SizedBox(height: 16),

            _InfoRow(
              icon: Icons.location_on,
              text: place.address,
              iconColor: scheme.primary,
            ),

            if (place.website.isNotEmpty)
              _InfoRow(
                icon: Icons.link,
                text: place.website,
                isLink: true,
                onTap: () => UrlHelper.launchWebsite(place.website),
              ),

            if (place.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                place.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color
                      ?.withOpacity(0.95),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RatingChip extends StatelessWidget {
  final PlaceDetailModel place;

  const _RatingChip({required this.place});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (place.totalReviews == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: scheme.surfaceVariant,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          'Нет отзывов',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 18),
          const SizedBox(width: 4),
          Text(
            place.averageRating.toStringAsFixed(1),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '(${place.totalReviews})',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isLink;
  final VoidCallback? onTap;
  final Color? iconColor;

  const _InfoRow({
    required this.icon,
    required this.text,
    this.isLink = false,
    this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: iconColor ?? theme.iconTheme.color?.withOpacity(0.8),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Text(
                text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isLink
                      ? theme.colorScheme.primary
                      : theme.textTheme.bodyMedium?.color,
                  decoration:
                      isLink ? TextDecoration.underline : TextDecoration.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
