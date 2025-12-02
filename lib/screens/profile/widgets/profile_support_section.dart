// lib/screens/profile/widgets/profile_support_section.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/screens/info/widgets/support_sheet.dart';
import 'package:mobile/widgets/app_version_subtitle.dart'; // 👈 новый импорт

class ProfileSupportSection extends StatelessWidget {
  const ProfileSupportSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Помощь и информация',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Material(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Написать в поддержку'),
                  onTap: () => showSupportSheet(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Политика конфиденциальности'),
                  onTap: () {
                    context.push('/privacy');
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('О приложении'),
                  subtitle: const AppVersionSubtitle(), // 👈 тут живая версия
                  onTap: () {
                    // позже сюда можно сделать отдельный экран "О приложении"
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
