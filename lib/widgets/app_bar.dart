import 'package:flutter/material.dart';
import 'package:mobile/utils/back_button_handler.dart';

class AppBarContainer extends StatelessWidget {
  final Widget child;
  final double height;

  const AppBarContainer({
    super.key,
    required this.child,
    this.height = kToolbarHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: false, // нижняя часть нам не нужна
      child: Container(
        height: height,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
              ), // 👈 теперь тут
              child: child,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 1,
                width: double.infinity,
                color: Colors.grey.shade300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;
  final String? fallbackRoute;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.actions,
    this.onBackPressed,
    this.fallbackRoute,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final bool canPop = Navigator.canPop(context);

    return AppBarContainer(
      child: Row(
        children: [
          if (showBackButton || canPop)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (onBackPressed != null) {
                  onBackPressed!();
                } else {
                  BackButtonHandler.handle(
                    context,
                    fallbackRoute: fallbackRoute,
                  );
                }
              },
            )
          else
            const SizedBox(width: 48), // 👈 добавим симметрию

          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // 👇 действия, если есть, иначе симметричный отступ
          if (actions != null && actions!.isNotEmpty)
            Row(mainAxisSize: MainAxisSize.min, children: actions!)
          else
            const SizedBox(width: 48), // 👈 зеркалим отступ
        ],
      ),
    );
  }
}
