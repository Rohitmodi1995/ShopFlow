class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double discountPrice;
  final String imageUrl;
  final List<String> images;
  final String categoryId;
  final double rating;
  final int stock;
  final bool isFeatured;
  final bool isActive;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.discountPrice,
    required this.imageUrl,
    required this.images,
    required this.categoryId,
    required this.rating,
    required this.stock,
    required this.isFeatured,
    required this.isActive,
  });

  factory ProductModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return ProductModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      discountPrice: (map['discountPrice'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      images: map['images'] != null
          ? List<String>.from(map['images'])
          : [],
      categoryId: map['categoryId'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      stock: map['stock'] ?? 0,
      isFeatured: map['isFeatured'] ?? false,
      isActive: map['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'discountPrice': discountPrice,
      'imageUrl': imageUrl,
      'images': images,
      'categoryId': categoryId,
      'rating': rating,
      'stock': stock,
      'isFeatured': isFeatured,
      'isActive': isActive,
    };
  }
}