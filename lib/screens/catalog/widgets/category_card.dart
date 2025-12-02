import 'package:flutter/material.dart';
import 'package:mobile/models/category.dart';
import 'package:mobile/widgets/category_icon.dart';

class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;

  /// compact = true  → плитка в гриде (как на госуслугах)
  /// compact = false → обычная «широкая» карточка с подзаголовком
  final bool compact;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bool hasChildren = category.children.isNotEmpty;

    Color withAlpha(Color base, double alpha) =>
        base.withValues(alpha: alpha); // удобный шорткат

    Widget buildCompact() {
      return Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: withAlpha(Colors.black, 0.04),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: withAlpha(Colors.black, 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: withAlpha(scheme.primary, 0.06),
                shape: BoxShape.circle,
                border: Border.all(
                  color: withAlpha(scheme.primary, 0.4),
                  width: 1,
                ),
              ),
              child: Center(
                child: CategoryIcon(
                  iconKey: category.icon,
                  size: 20,
                  color: scheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                category.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  height: 1.15,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    Widget buildFull() {
      return Container (
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: withAlpha(Colors.black, 0.04),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: withAlpha(Colors.black, 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: withAlpha(scheme.primary, 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: withAlpha(scheme.primary, 0.4),
                  width: 1,
                ),
              ),
              child: Center(
                child: CategoryIcon(
                  iconKey: category.icon,
                  size: 24,
                  color: scheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    category.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Локаций: ${category.placeCount}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme
                          .textTheme
                          .bodySmall
                          ?.color
                          // color? может быть null, тогда null и останется
                          ?.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              hasChildren ? Icons.chevron_right : Icons.circle,
              color: hasChildren
                  ? Colors.grey[500]
                  : (Colors.grey[400] ?? Colors.grey)
                      .withValues(alpha: 0.7),
              size: hasChildren ? 22 : 8,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: compact
          ? const EdgeInsets.all(0) // в гриде
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          splashColor: withAlpha(scheme.primary, 0.06),
          child: compact ? buildCompact() : buildFull(),
        ),
      ),
    );
  }
}
