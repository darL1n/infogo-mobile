import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/widgets/app_bar.dart';

class BaseLayout extends StatelessWidget {
  final String title;
  final Widget child;
  final bool showBackButton;
  final bool showBottomNavigation;
  final int currentIndex;
  final VoidCallback? onBackPressed;
  final String? fallbackRoute;
  final List<Widget>? actions;
  final PreferredSizeWidget? appBar;
  final bool useLayout;

  const BaseLayout({
    super.key,
    required this.title,
    required this.child,
    this.showBackButton = false,
    this.showBottomNavigation = true,
    this.currentIndex = 0,
    this.onBackPressed,
    this.fallbackRoute,
    this.actions,
    this.appBar,
    this.useLayout = true,
  });

  static const List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: "Главная"),
    BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "Справочник"),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: "Профиль"),
  ];

  static const List<String> _routes = [
    '/home',
    '/catalog',
    '/profile',
  ];

  @override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  // 🎨 Настройка системных панелей
  final overlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,                 // фон под статус-баром = фон экрана
    statusBarIconBrightness: Brightness.dark,           // иконки в статус-баре (Android)
    statusBarBrightness: Brightness.light,              // для iOS (обратная логика)
    systemNavigationBarColor: theme.scaffoldBackgroundColor, // цвет нижней панели с кнопками
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  // fullscreen-экраны без layout
  if (!useLayout) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: child,
      ),
    );
  }

  final location = GoRouterState.of(context).uri.toString();
  final isPlaceDetail = location.contains('/place/');

  final PreferredSizeWidget? effectiveAppBar = isPlaceDetail
      ? null
      : appBar ??
          CustomAppBar(
            title: title,
            showBackButton: showBackButton,
            onBackPressed: onBackPressed,
            fallbackRoute: fallbackRoute,
            actions: actions,
          );

  return AnnotatedRegion<SystemUiOverlayStyle>(
    value: overlayStyle,
    child: Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: effectiveAppBar == null
          ? null
          : PreferredSize(
              preferredSize: effectiveAppBar.preferredSize ??
                  const Size.fromHeight(kToolbarHeight),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeIn,
                switchOutCurve: Curves.easeOut,
                child: effectiveAppBar,
              ),
            ),
      body: child,
      bottomNavigationBar: showBottomNavigation
          ? AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 250),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: BottomNavigationBar(
                  currentIndex: currentIndex,
                  onTap: (index) {
                    if (index == currentIndex) return;
                    context.go(_routes[index]);
                  },
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  selectedItemColor:
                      theme.bottomNavigationBarTheme.selectedItemColor ??
                          colorScheme.primary,
                  unselectedItemColor:
                      theme.bottomNavigationBarTheme.unselectedItemColor ??
                          Colors.grey,
                  showUnselectedLabels: true,
                  type: BottomNavigationBarType.fixed,
                  items: _navItems,
                ),
              ),
            )
          : null,
    ),
  );
}

}
