import 'package:flutter/material.dart';
import 'package:mobile/utils/category_icon_mapper.dart';

class CategoryIcon extends StatelessWidget {
  final String iconKey;
  final double size;
  final Color? color;

  const CategoryIcon({
    super.key,
    required this.iconKey,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = color ?? theme.colorScheme.primary;

    return Icon(
      categoryIcons[iconKey] ?? categoryIcons['default']!,
      size: size,
      color: iconColor,
    );
  }
}
