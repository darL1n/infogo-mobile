// lib/screens/profile/widgets/profile_quick_actions.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileQuickActions extends StatelessWidget {
  final bool isAuth;

  const ProfileQuickActions({super.key, required this.isAuth});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final items = <_QuickActionItem>[
      _QuickActionItem(
        icon: Icons.history,
        label: 'История',
        requiresAuth: true,
        onTap: () => context.push('/history'),
      ),
      _QuickActionItem(
        icon: Icons.favorite,
        label: 'Избранное',
        requiresAuth: true,
        onTap: () => context.push('/favorites'),
      ),
      _QuickActionItem(
        icon: Icons.reviews,
        label: 'Мои отзывы',
        requiresAuth: true,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Экран «Мои отзывы» появится позже'),
            ),
          );
        },
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: items.map((item) {
            final locked = item.requiresAuth && !isAuth;

            final iconColor =
                locked ? theme.disabledColor : theme.colorScheme.primary;

            final textColor = locked
                ? theme.textTheme.bodySmall?.color?.withOpacity(0.5)
                : theme.textTheme.bodySmall?.color;

            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  if (locked) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Войдите, чтобы использовать этот раздел',
                        ),
                      ),
                    );
                    context.push('/login');
                  } else {
                    item.onTap();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 4,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        size: 22,
                        color: iconColor,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _QuickActionItem {
  final IconData icon;
  final String label;
  final bool requiresAuth;
  final VoidCallback onTap;

  _QuickActionItem({
    required this.icon,
    required this.label,
    required this.requiresAuth,
    required this.onTap,
  });
}
