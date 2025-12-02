import 'package:flutter/material.dart';

class PlaceDetailError extends StatelessWidget {
  final VoidCallback onRetry;

  const PlaceDetailError({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: scheme.error, size: 56),
              const SizedBox(height: 12),
              Text(
                "Ошибка загрузки",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Не удалось получить данные о месте.\nПопробуйте ещё раз.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color:
                      theme.textTheme.bodySmall?.color?.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onRetry,
                child: const Text("Повторить"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
