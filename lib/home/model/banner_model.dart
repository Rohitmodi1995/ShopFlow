class BannerModel {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String mobileImageUrl;
  final bool isActive;
  final int order;

  const BannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.mobileImageUrl,
    required this.isActive,
    required this.order,
  });

  factory BannerModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return BannerModel(
      id: id,
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      mobileImageUrl: map['mobileImageUrl'] ?? '',
      isActive: map['isActive'] ?? false,
      order: map['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'mobileImageUrl': mobileImageUrl,
      'isActive': isActive,
      'order': order,
    };
  }
}