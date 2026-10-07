class CategoryModel {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String? thumbnailUrl;
  final int productsCount;

  const CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.thumbnailUrl,
    this.productsCount = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    String? imgUrl;
    String? thumbUrl;
    if (json['image'] is Map<String, dynamic>) {
      final imgMap = json['image'] as Map<String, dynamic>;
      imgUrl = imgMap['url'] as String?;
      thumbUrl = imgMap['thumbnail'] as String? ?? imgMap['preview'] as String?;
    } else if (json['image'] is String) {
      imgUrl = json['image'] as String;
    }

    return CategoryModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      imageUrl: imgUrl,
      thumbnailUrl: thumbUrl,
      productsCount: json['products_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      if (imageUrl != null) 'image': {'url': imageUrl, 'thumbnail': thumbnailUrl},
      'products_count': productsCount,
    };
  }
}
