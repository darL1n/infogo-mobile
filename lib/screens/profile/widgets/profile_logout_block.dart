// lib/screens/profile/widgets/profile_logout_block.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile/widgets/custom_button.dart';
import '../views/profile_view_model.dart';

class ProfileLogoutBlock extends StatelessWidget {
  final ProfileViewModel vm;

  const ProfileLogoutBlock({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Future<void> _confirmLogout() async {
      final shouldLogout = await showDialog<bool>(
            context: context,
            builder: (dialogCtx) => AlertDialog(
              title: const Text('Выйти из аккаунта?'),
              content: const Text('Вы сможете войти снова по номеру телефона.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(false),
                  child: const Text('Отмена'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(true),
                  child: const Text(
                    'Выйти',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ],
            ),
          ) ??
          false;

      if (!shouldLogout) return;

      await vm.logout();
      if (context.mounted) {
        context.go('/login');
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Аккаунт',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        CustomButton(
          text: 'Выйти',
          onPressed: _confirmLogout,
          color: Colors.redAccent,
          textColor: Colors.white,
        ),
      ],
    );
  }
}
