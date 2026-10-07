class TagModel {
  final int id;
  final String name;
  final int? productsCount;

  const TagModel({
    required this.id,
    required this.name,
    this.productsCount,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      productsCount: json['products_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (productsCount != null) 'products_count': productsCount,
    };
  }
}
