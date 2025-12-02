import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/widgets/app_bar.dart';
import 'package:mobile/widgets/common_input.dart';
import 'package:mobile/widgets/custom_back_button.dart';

class PlacesAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? fallbackRoute;
  final String? query; // 👈 новый проп

  const PlacesAppBar({
    super.key,
    this.fallbackRoute,
    this.query,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight); // 56.0

  @override
  Widget build(BuildContext context) {
    final String placeholder = (query != null && query!.trim().isNotEmpty)
        ? query!.trim()
        : 'Поиск мест…';

    return SafeArea(
      bottom: false,
      child: AppBarContainer(
        height: preferredSize.height,
        child: Row(
          children: [
            CustomBackButton(fallbackRoute: fallbackRoute),
            const SizedBox(width: 8),
            Expanded(
              child: CommonInput(
                text: placeholder,          // 👈 сюда подставляем либо query, либо дефолт
                icon: Icons.search,
                onTap: () =>
                    context.push('/search', extra: {'useLayout': false}),
                padding: EdgeInsets.zero,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.map),
              onPressed: () => context.push('/map'),
            ),
          ],
        ),
      ),
    );
  }
}
