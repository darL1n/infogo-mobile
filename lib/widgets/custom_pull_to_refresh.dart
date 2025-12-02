import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomPullToRefresh extends StatefulWidget {
  final Future<void> Function() onRefresh;
  final List<Widget> slivers;

  /// Максимальная "глубина" перетаскивания для анимации.
  final double maxDragOffset;

  /// На сколько нужно "дотянуть", чтобы сработало обновление.
  final double triggerOffset;

  /// Минимальное время показа индикатора, даже при очень быстром запросе.
  final Duration minIndicatorDuration;

  const CustomPullToRefresh({
    super.key,
    required this.onRefresh,
    required this.slivers,
    this.maxDragOffset = 80,
    this.triggerOffset = 60,
    this.minIndicatorDuration = const Duration(milliseconds: 600),
  });

  @override
  State<CustomPullToRefresh> createState() => _CustomPullToRefreshState();
}

class _CustomPullToRefreshState extends State<CustomPullToRefresh>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0.0;
  bool _isRefreshing = false;
  bool _thresholdPassed = false; // чтобы не спамить haptic

  // direction lock для жеста
  bool _dragDirectionResolved = false;
  bool _isVerticalDrag = false;
  double _totalDx = 0.0;
  double _totalDy = 0.0;


  late final AnimationController _resetController;
  Animation<double>? _resetAnimation;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    )..addListener(_onAnimateReset);
  }

  void _onAnimateReset() {
    final anim = _resetAnimation;
    if (anim == null) return;
    setState(() {
      _dragOffset = anim.value;
    });
  }

  @override
  void dispose() {
    _resetController
      ..removeListener(_onAnimateReset)
      ..dispose();
    super.dispose();
  }

  void _animateDragOffsetTo(double target) {
    if (_dragOffset == target) return;

    _resetController.reset();
    _resetAnimation = Tween<double>(
      begin: _dragOffset,
      end: target,
    ).animate(CurvedAnimation(parent: _resetController, curve: Curves.easeOut));
    _resetController.forward();
  }

  void _setDragOffset(double value) {
    final clamped = value.clamp(0.0, widget.maxDragOffset);

    if (clamped == _dragOffset) return;

    final wasBelow = _dragOffset < widget.triggerOffset;
    final nowAbove = clamped >= widget.triggerOffset;

    setState(() {
      _dragOffset = clamped;
    });

    // haptic, когда первый раз пересекаем порог
    if (!_isRefreshing && wasBelow && nowAbove && !_thresholdPassed) {
      _thresholdPassed = true;
      HapticFeedback.mediumImpact();
    }

    if (!_isRefreshing && clamped < widget.triggerOffset) {
      _thresholdPassed = false;
    }
  }

  void _resetDragOffset() {
    if (_dragOffset == 0) return;
    _thresholdPassed = false;
    _animateDragOffsetTo(0.0);
  }

  Future<void> _startRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    // фиксируем кружок примерно на высоте триггера
    _animateDragOffsetTo(widget.triggerOffset);

    final startedAt = DateTime.now();

    try {
      debugPrint('CustomPullToRefresh: startRefresh');
      await widget.onRefresh();
    } catch (e) {
      debugPrint('CustomPullToRefresh: refresh error: $e');
    } finally {
      if (!mounted) return;

      // выдерживаем минимальное время показа индикатора
      final elapsed = DateTime.now().difference(startedAt);
      final rest = widget.minIndicatorDuration - elapsed;
      if (rest > Duration.zero) {
        await Future.delayed(rest);
      }

      if (!mounted) return;

      setState(() {
        _isRefreshing = false;
      });

      // плавно уезжаем вверх
      _resetDragOffset();
    }
  }

  void _resetDirectionLock() {
    _dragDirectionResolved = false;
    _isVerticalDrag = false;
    _totalDx = 0.0;
    _totalDy = 0.0;
  }

  void _resolveDragDirection(DragUpdateDetails drag) {
    if (_dragDirectionResolved) return;

    // копим суммарное движение за жест
    _totalDx += drag.delta.dx;
    _totalDy += drag.delta.dy;

    final absDx = _totalDx.abs();
    final absDy = _totalDy.abs();

    // пока палец почти не сдвинулся — ничего не решаем
    const kMinDistance = 6.0; // можно 8.0 сделать, если хочешь ещё жёстче
    if (absDx < kMinDistance && absDy < kMinDistance) {
      return;
    }

    // считаем vertical-gest, только если:
    //  - вертикаль заметно доминирует (строже, чем просто dy > dx)
    //  - и движение вниз
    const kVerticalDominance = 1.5; // dy должно быть в 1.5 раза больше dx
    if (absDy > absDx * kVerticalDominance && _totalDy > 0) {
      _isVerticalDrag = true;
    } else {
      _isVerticalDrag = false;
    }

    _dragDirectionResolved = true;
  }

  bool _onScrollNotification(ScrollNotification notification) {
    // только верхний скролл (depth == 0)
    if (notification.depth != 0) return false;

    final metrics = notification.metrics;
    if (metrics.axis != Axis.vertical) return false;

    final pixels = metrics.pixels;
    final atTop = metrics.extentBefore <= 0.0 &&
        pixels <= metrics.minScrollExtent + 0.5;

    if (notification is ScrollStartNotification) {
      // новый жест — сбрасываем фиксацию направления
      _resetDirectionLock();
      return false;
    }

    if (notification is ScrollEndNotification) {
      // палец отпустили
      if (_dragOffset >= widget.triggerOffset && atTop && _isVerticalDrag) {
        _startRefresh();
      } else {
        _resetDragOffset();
      }

      _resetDirectionLock();
      return false;
    }

    // пока идёт refresh — руками offset не трогаем
    if (_isRefreshing) return false;

    if (notification is OverscrollNotification && atTop) {
      final drag = notification.dragDetails;
      if (drag != null) {
        _resolveDragDirection(drag);
      }

      if (!_isVerticalDrag) {
        // горизонтальный или "вверх" — не наш случай
        return false;
      }

      if (notification.overscroll < 0) {
        final delta = -notification.overscroll;
        _setDragOffset(_dragOffset + delta);
      }
    } else if (notification is ScrollUpdateNotification && atTop) {
      final drag = notification.dragDetails;
      if (drag != null) {
        _resolveDragDirection(drag);
      }

      if (!_isVerticalDrag) {
        // если это свайп влево/вправо — не вмешиваемся
        return false;
      }

      if (drag != null && drag.delta.dy > 0) {
        _setDragOffset(_dragOffset + drag.delta.dy);
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final progress = (_dragOffset / widget.triggerOffset).clamp(
      0.0,
      1.0,
    ); // 0..1

    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: _onScrollNotification,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(), //ClampingScrollPhysics
            ),
            slivers: widget.slivers,
          ),
        ),

        // Индикатор поверх контента
        if (_dragOffset > 0 || _isRefreshing)
          Positioned(
            top: topPadding + 8,
            left: 0,
            right: 0,
            child: Center(
              child: Transform.translate(
                // во время перетаскивания кружок "едет" за пальцем,
                // во время refresh — чуть менее подвижен
                offset: Offset(0, _dragOffset * (_isRefreshing ? 0.15 : 0.25)),
                child: _RefreshIndicatorCircle(
                  isRefreshing: _isRefreshing,
                  progress: progress,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _RefreshIndicatorCircle extends StatelessWidget {
  final bool isRefreshing;
  final double progress; // 0..1

  const _RefreshIndicatorCircle({
    required this.isRefreshing,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final t = (isRefreshing ? 1.0 : progress).clamp(0.0, 1.0);

    // немножко "растягиваем" и увеличиваем тень по мере тянучки
    final scale = 0.8 + 0.2 * t; // 0.8 → 1.0
    final blur = 6.0 + 4.0 * t; // 6 → 10
    final offsetY = 2.0 + 2.0 * t;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: (isRefreshing || progress > 0) ? 1 : 0,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: cs.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: blur,
                offset: Offset(0, offsetY),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child:
                isRefreshing
                    ? CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(cs.primary),
                    )
                    : Transform.rotate(
                      angle: t * math.pi,
                      child: Icon(
                        Icons.arrow_downward_rounded,
                        size: 18,
                        color: cs.primary.withValues(alpha: 0.9),
                      ),
                    ),
          ),
        ),
      ),
    );
  }
}
