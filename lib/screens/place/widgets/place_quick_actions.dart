// place_quick_actions.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/models/place_detail.dart';
import 'package:mobile/utils/url_helper.dart';

class PlaceQuickActions extends StatelessWidget {
  final PlaceDetailModel place;

  const PlaceQuickActions({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final hasPhone = place.contactPhone.isNotEmpty;
    final hasMap = place.latitude != null && place.longitude != null;
    final hasWebsite = place.website.isNotEmpty;

    final actions = <_QuickAction>[];

    // Здесь делаем «лайт» набор: сайт + поделиться (+ звонок/маршрут опционально)
    if (hasWebsite) {
      actions.add(
        _QuickAction(
          icon: Icons.link,
          label: 'Сайт',
          onTap: () => UrlHelper.launchWebsite(place.website),
        ),
      );
    }

    if (hasMap) {
      actions.add(
        _QuickAction(
          icon: Icons.map_outlined,
          label: 'Маршрут',
          onTap: () {
            context.push(
              '/map',
              extra: {'highlightPlaceId': place.id},
            );
          },
        ),
      );
    }

    if (hasPhone) {
      actions.add(
        _QuickAction(
          icon: Icons.call,
          label: 'Позвонить',
          onTap: () => UrlHelper.launchPhoneCall(place.contactPhone),
        ),
      );
    }

    actions.add(
      _QuickAction(
        icon: Icons.share,
        label: 'Поделиться',
        onTap: () {
          // TODO: интегрировать share_plus
        },
      ),
    );

    if (actions.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Быстрые действия',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: actions
                .map(
                  (a) => _QuickActionChip(
                    action: a,
                    scheme: scheme,
                    theme: theme,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class _QuickActionChip extends StatelessWidget {
  final _QuickAction action;
  final ColorScheme scheme;
  final ThemeData theme;

  const _QuickActionChip({
    required this.action,
    required this.scheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: action.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: scheme.outlineVariant.withOpacity(0.7),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              action.icon,
              size: 18,
              color: scheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              action.label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
