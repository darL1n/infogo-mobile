

import 'package:mobile/models/category.dart';

List<CategoryModel> buildCategoryTree(List<CategoryModel> categories) {
  // Группируем категории по parentId
  final Map<int?, List<CategoryModel>> map = {};
  for (var category in categories) {
    map.putIfAbsent(category.parentId, () => []).add(category);
  }

  // Верхний уровень – те, у которых parentId == null
  final List<CategoryModel> tree = map[null] ?? [];

  void assignChildren(CategoryModel parent) {
    final children = map[parent.id] ?? [];
    parent.children.addAll(children);
    for (var child in children) {
      assignChildren(child);
    }
  }

  for (var cat in tree) {
    assignChildren(cat);
  }

  return tree;
}