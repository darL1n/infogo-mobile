import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Page<T> buildSlideTransitionPage<T>({
  required Widget child,
  required LocalKey key,
  bool withFadeBackground = true, // 👈 параметр по умолчанию
}) {
  return CustomTransitionPage<T>(
    key: key,
    opaque: false,
    barrierColor:
        withFadeBackground ? Colors.white.withAlpha((0.3 * 255).round()) : null,
    child:
        withFadeBackground
            ? child
            : Container(color: Colors.white, child: child),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeOut;

      final tween = Tween(
        begin: begin,
        end: end,
      ).chain(CurveTween(curve: curve));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}

Page<T> buildSlideExitTransitionPage<T>({
  required Widget child,
  required LocalKey key,
  bool withFadeBackground = true,
}) {
  return CustomTransitionPage<T>(
    key: key,
    opaque: false,
    barrierColor:
        withFadeBackground ? Colors.white.withAlpha((0.3 * 255).round()) : null,
    child: withFadeBackground
        ? child
        : Container(color: Colors.white, child: child),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset.zero;
      const end = Offset(-1.0, 0.0); // ⬅️ уходит влево
      const curve = Curves.easeInOut;

      final exitTween = Tween(
        begin: begin,
        end: end,
      ).chain(CurveTween(curve: curve));

      return Stack(
        children: [
          // 👈 Анимация ухода предыдущего экрана
          SlideTransition(
            position: secondaryAnimation.drive(exitTween),
            child: child,
          ),
        ],
      );
    },
  );
}


Page<T> buildCleanFadePage<T>({
  required Widget child,
  required LocalKey key,
}) {
  return CustomTransitionPage<T>(
    key: key,
    opaque: false, // 👈 пусть будет прозрачным, но...
    barrierDismissible: false,
    barrierColor: Colors.white, // 👈 белый фон под анимацией
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutQuad,
      );

      return FadeTransition(
        opacity: curved,
        child: child,
      );
    },
    child: child,
  );
}


Page<T> buildSlideUpPage<T>({
  required Widget child,
  required LocalKey key,
}) {
  return CustomTransitionPage<T>(
    key: key,
    opaque: true, // 👈 полностью перекрывает предыдущий экран
    barrierDismissible: false,
    barrierColor: Colors.white, // 👈 моментально белый фон
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slideAnimation = Tween<Offset>(
        begin: const Offset(0.0, 1.0), // 👈 снизу вверх
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(animation);

      return SlideTransition(
        position: slideAnimation,
        child: child,
      );
    },
    child: child,
  );
}


Page<T> buildInstantPage<T>({
  required Widget child,
  required LocalKey key,
  bool withFadeBackground = false,
}) {
  return CustomTransitionPage<T>(
    key: key,
    opaque: !withFadeBackground,
    barrierColor:
        withFadeBackground ? Colors.white.withAlpha((0.3 * 255).round()) : null,
    child:
        withFadeBackground
            ? child
            : Container(color: Colors.white, child: child),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return child; // 🔥 Без анимации, без fade
    },
  );
}
