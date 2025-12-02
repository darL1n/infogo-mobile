// lib/screens/map/widgets/map_root_categories_sheet.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:mobile/models/category.dart';
import 'package:mobile/providers/category_provider.dart';
import 'package:mobile/screens/catalog/widgets/category_card.dart';

class MapRootCategoriesSheet extends StatelessWidget {
  final ScrollController scrollController;
  final ValueChanged<CategoryModel> onCategorySelected;

  const MapRootCategoriesSheet({
    super.key,
    required this.scrollController,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, _) {
          if (categoryProvider.isLoading && !categoryProvider.isLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final categories = categoryProvider.categories;
          if (categories.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Категорий пока нет'),
              ),
            );
          }

          return CustomScrollView(
            controller: scrollController,
            slivers: [
              // шапка с хэндлом + заголовок
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'Категории на карте',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // сетка корневых категорий — используем твой CategoryCard(compact: true)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    mainAxisExtent: 72,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final category = categories[index];
                      return CategoryCard(
                        category: category,
                        compact: true,          // 👈 плиточный режим
                        onTap: () => onCategorySelected(category),
                      );
                    },
                    childCount: categories.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
