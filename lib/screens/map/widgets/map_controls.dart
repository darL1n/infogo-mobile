import 'package:flutter/material.dart';

class MapZoomButton extends StatelessWidget {
  const MapZoomButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return FloatingActionButton.small(
      heroTag: null,
      onPressed: onPressed,
      backgroundColor: primary,
      foregroundColor: Colors.white,
      child: Icon(icon),
    );
  }
}

class MyLocationButton extends StatelessWidget {
  const MyLocationButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return FloatingActionButton.small(
      heroTag: null,
      onPressed: isLoading ? null : onPressed,
      backgroundColor: primary,
      foregroundColor: Colors.white,
      child: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Icons.my_location),
    );
  }
}
