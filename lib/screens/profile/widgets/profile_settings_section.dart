// lib/screens/profile/widgets/profile_settings_section.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../views/profile_view_model.dart';

class ProfileSettingsSection extends StatelessWidget {
  final ProfileViewModel vm;

  const ProfileSettingsSection({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Настройки приложения',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _SettingsTile(
            leadingIcon: Icons.language,
            title: 'Язык',
            subtitle: vm.languageLabel,
            onTap: () => context.push(
              '/onboarding/language',
              extra: {'redirectTo': '/profile'},
            ),
          ),
          const SizedBox(height: 6),
          _SettingsTile(
            leadingIcon: Icons.location_city,
            title: 'Город',
            subtitle: vm.cityName,
            onTap: () => context.push('/onboarding/location'),
          ),
          const SizedBox(height: 6),
          _SettingsTile(
            leadingIcon: Icons.my_location,
            title: 'Определять город по геолокации',
            subtitle: 'Позже можно будет включить/отключить',
            trailing: Switch(
              value: false,
              onChanged: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Автообновление города добавим позже'),
                  ),
                );
              },
              activeColor: scheme.primary,
            ),
            onTap: null,
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData leadingIcon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.leadingIcon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(12),
      child: ListTile(
        leading: Icon(leadingIcon, color: theme.colorScheme.primary),
        title: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
          ),
        ),
        trailing: trailing ??
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: onTap,
      ),
    );
  }
}
