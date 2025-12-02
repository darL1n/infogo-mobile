// action_buttons.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/models/place_detail.dart';
import 'package:mobile/utils/url_helper.dart';

class PlaceActionButtons extends StatelessWidget {
  final PlaceDetailModel place;

  const PlaceActionButtons({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final hasPhone = place.contactPhone.isNotEmpty;
    final hasMap = place.latitude != null && place.longitude != null;

    if (!hasPhone && !hasMap) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
          bottom: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Row(
        children: [
          if (hasPhone)
            Expanded(
              child: _WideButton(
                icon: Icons.call,
                label: 'Позвонить',
                color: scheme.primary,
                onTap: () =>
                    UrlHelper.launchPhoneCall(place.contactPhone),
              ),
            ),
          if (hasPhone && hasMap) const SizedBox(width: 12),
          if (hasMap)
            Expanded(
              child: _WideButton(
                icon: Icons.map,
                label: 'Маршрут',
                color: scheme.secondary,
                onTap: () {
                  context.push(
                    '/map',
                    extra: {'highlightPlaceId': place.id},
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _WideButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _WideButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilledButton.icon(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      icon: Icon(icon, size: 22, color: Colors.white), // 👈 вот так
      label: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}