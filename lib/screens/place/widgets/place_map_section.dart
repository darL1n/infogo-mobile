import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/models/place_detail.dart';

class PlaceMapSection extends StatelessWidget {
  final PlaceDetailModel place;

  const PlaceMapSection({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    final lat = place.latitude;
    final lng = place.longitude;

    if (lat == null || lng == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Material(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: () {
            context.push(
              '/map',
              extra: {'highlightPlaceId': place.id},
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.primary.withOpacity(0.12),
                  ),
                  child: Icon(
                    Icons.place_outlined,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Как добраться',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        place.address,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color
                              ?.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: scheme.outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
