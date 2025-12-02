import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BackButtonHandler {
  static void handle(BuildContext context, {String? fallbackRoute}) {
    final router = GoRouter.of(context);

    if (router.canPop()) {
      print('can pop');
      router.pop();
    } else {
      print(fallbackRoute);
      router.push(fallbackRoute ?? '/home'); // Используем '/main/home' если fallbackRoute == null
    }
  }
}
