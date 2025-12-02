import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/utils/back_button_handler.dart';

class SwipeBackWrapper extends StatefulWidget {
  final Widget child;
  final double swipeThreshold;
  final String? fallbackRoute; // новый необязательный параметр

  /// [child] – экран, который нужно обернуть.
  /// [swipeThreshold] – порог скорости свайпа для срабатывания возврата (по умолчанию 300 пикс/сек).
  const SwipeBackWrapper({
    super.key,
    required this.child,
    this.fallbackRoute,
    this.swipeThreshold = 300,
  });

  @override
  _SwipeBackWrapperState createState() => _SwipeBackWrapperState();
}

class _SwipeBackWrapperState extends State<SwipeBackWrapper>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _controller.addListener(() {
      setState(() {
        _dragOffset = _animation.value;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateBack() {
    _animation = Tween<double>(
      begin: _dragOffset,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        // Обновляем смещение, учитывая только свайп вправо
        setState(() {
          _dragOffset += details.delta.dx;
          if (_dragOffset < 0) _dragOffset = 0;
        });
      },
      onHorizontalDragEnd: (details) {
        if (details.velocity.pixelsPerSecond.dx > widget.swipeThreshold ||
            _dragOffset > MediaQuery.of(context).size.width / 3) {
          final router = GoRouter.of(context);
          if (router.canPop()) {
            router.pop();
          } else {
            BackButtonHandler.handle(context, fallbackRoute: widget.fallbackRoute);
          }
        } else {
          _animateBack();
        }
      },
      child: Transform.translate(
        offset: Offset(_dragOffset, 0),
        child: widget.child,
      ),
    );
  }
}
