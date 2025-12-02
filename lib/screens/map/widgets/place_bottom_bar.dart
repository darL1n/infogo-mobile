// lib/screens/map/widgets/place_bottom_bar.dart
import 'package:flutter/material.dart';

class PlaceBottomBar extends StatelessWidget {
  final VoidCallback onRoutePressed;
  final VoidCallback onOpenDetails;

  const PlaceBottomBar({
    super.key,
    required this.onRoutePressed,
    required this.onOpenDetails,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    );

    final primaryStyle = FilledButton.styleFrom(
      shape: shape,
      minimumSize: const Size.fromHeight(46),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      textStyle: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );

    final secondaryStyle = OutlinedButton.styleFrom(
      shape: shape,
      minimumSize: const Size.fromHeight(46),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      side: BorderSide(
        color: theme.colorScheme.primary.withOpacity(0.3),
        width: 1.2,
      ),
      textStyle: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w500,
      ),
    );

    return Material(
      elevation: 8,
      color: theme.colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 8 + bottomInset),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  style: primaryStyle,
                  onPressed: onRoutePressed,
                  icon: const Icon(Icons.directions),
                  label: const Text('Как добраться'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  style: secondaryStyle,
                  onPressed: onOpenDetails,
                  icon: const Icon(Icons.place_outlined),
                  label: const Text('Открыть место'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
