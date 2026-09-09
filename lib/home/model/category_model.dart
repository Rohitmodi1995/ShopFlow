class CategoryModel {
  final String id;
  final String name;
  final String imageUrl;
  final bool isActive;
  final int order;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.isActive,
    required this.order,
  });

  factory CategoryModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return CategoryModel(
      id: id,
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      isActive: map['isActive'] ?? false,
      order: map['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'order': order,
    };
  }
}