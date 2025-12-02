import 'package:flutter/material.dart';

class NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    // Убираем вспышку (glow)
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    // Используем жёсткое поведение без bounce
    return const ClampingScrollPhysics();
  }
}
