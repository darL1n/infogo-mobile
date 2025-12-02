import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/widgets/common_input.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonInput(
      text: 'Куда сходить сегодня?',
      icon: Icons.search,
      onTap: () => context.push('/search', extra: {'useLayout': false}),

      padding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    );
  }
}
