// home_app_bar.dart
import 'package:flutter/material.dart';
import 'package:mobile/widgets/app_bar.dart';
import 'package:provider/provider.dart';
import 'package:mobile/providers/city_provider.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onSearchTap;
  final VoidCallback onCityTap;

  const HomeAppBar({
    super.key,
    required this.onSearchTap,
    required this.onCityTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cityName =
        context.watch<CityProvider>().currentCity?.name ?? 'Выбрать город';

    return AppBarContainer(
      child: Row(
        children: [
          // Левая часть — город
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onCityTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  cityName,
                  style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface
                            )
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 18,
                  color: theme.colorScheme.outline,
                ),
              ],
            ),
          ),

          const Spacer(),

          // Правая часть — иконка поиска
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onSearchTap,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
              child: Icon(
                Icons.search,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
