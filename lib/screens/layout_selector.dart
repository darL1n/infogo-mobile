import 'package:flutter/material.dart';
import 'package:mobile/widgets/base_layout.dart';
import 'package:mobile/providers/category_provider.dart';
import 'package:provider/provider.dart';

class TransitionAwareLayoutWrapper extends StatefulWidget {
  final Widget child;
  final String location;

  const TransitionAwareLayoutWrapper({
    super.key,
    required this.child,
    required this.location,
  });

  @override
  State<TransitionAwareLayoutWrapper> createState() =>
      _TransitionAwareLayoutWrapperState();
}

class _TransitionAwareLayoutWrapperState
    extends State<TransitionAwareLayoutWrapper> {
  bool _layoutEnabled = true;

  @override
  void initState() {
    super.initState();

    // ⏳ ждём завершения анимации, прежде чем применять useLayout = false
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final route = ModalRoute.of(context);
      if (route is PageRoute) {
        route.animation?.addStatusListener((status) {
          if (status == AnimationStatus.completed ||
              status == AnimationStatus.dismissed) {
            final isFullscreen = widget.location.startsWith('/search');
            setState(() {
              _layoutEnabled = !isFullscreen;
            });
          }
        });
      }
    });

    // начальное состояние
    _layoutEnabled = !widget.location.startsWith('/search');
  }

  @override
  Widget build(BuildContext context) {
    final uri = Uri.parse(widget.location);
    final segments = uri.pathSegments;

    int currentIndex = 0;
    String title = 'Главная';
    bool showBackButton = false;
    List<Widget> actions = [];

    if (widget.location.startsWith('/catalog')) {
      currentIndex = 1;
      if (segments.length >= 3) {
        final categoryId = int.tryParse(segments[2]);
        if (categoryId != null) {
          final categoryProvider =
              Provider.of<CategoryProvider>(context, listen: false);
          final category = categoryProvider.findCategoryById(categoryId);
          title = category?.name ?? 'Каталог';
        } else {
          title = 'Каталог';
        }
        showBackButton = true;
      } else {
        title = 'Каталог';
        showBackButton = false;
      }
    } else if (widget.location.startsWith('/profile')) {
      currentIndex = 2;
      title = 'Профиль';
    } else if (widget.location.startsWith('/favorites')) {
      currentIndex = 2;
      title = 'Избранное';
      showBackButton = true;
    } else if (widget.location.startsWith('/history')) {
      currentIndex = 2;
      title = 'История просмотров';
      showBackButton = true;
    }

    return BaseLayout(
      title: title,
      currentIndex: currentIndex,
      showBackButton: showBackButton,
      showBottomNavigation: true,
      actions: actions,
      useLayout: _layoutEnabled,
      child: widget.child,
    );
  }
}
