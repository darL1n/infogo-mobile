class CategoryModel {
  final int id;
  final String name;
  final int? parentId;
  final int placeCount;
  final String icon;
  final bool isLeafNode;
  List<CategoryModel> children;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    this.parentId,
    required this.isLeafNode,
    required this.placeCount,
    List<CategoryModel>? children,
  }) : children = children ?? [];

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
  return CategoryModel(
    id: json['id'] is int ? json['id'] as int : 0,
    name: json['name'] is String ? json['name'] as String : '',
    isLeafNode: json['is_leaf_node'] is bool ? json['is_leaf_node'] as bool : false,
    icon: json['icon'] is String ? json['icon'] as String : '',
    parentId: json['parent_id'] is int ? json['parent_id'] as int : null,
    placeCount: json['place_count'] is int ? json['place_count'] as int : 0,
  );
}
}


