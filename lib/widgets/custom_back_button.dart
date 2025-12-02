import 'package:flutter/material.dart';
import 'package:mobile/utils/back_button_handler.dart';

class CustomBackButton extends StatelessWidget {
  final String? fallbackRoute;

  const CustomBackButton({super.key, this.fallbackRoute});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => BackButtonHandler.handle(context, fallbackRoute: fallbackRoute),
    );
  }
}
