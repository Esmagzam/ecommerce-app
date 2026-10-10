import 'category_model.dart';
import 'tag_model.dart';

class ProductModel {
  final int id;
  final String name;
  final String? description;
  final num price;
  final String? imageUrl;
  final String? thumbnailUrl;
  final String? previewUrl;
  final List<CategoryModel> categories;
  final List<TagModel> tags;
  final String? createdAt;

  const ProductModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    this.thumbnailUrl,
    this.previewUrl,
    this.categories = const [],
    this.tags = const [],
    this.createdAt,
  });

  List<String> get imageGallery {
    final list = <String>[];
    if (imageUrl != null && imageUrl!.isNotEmpty) list.add(imageUrl!);
    if (previewUrl != null &&
        previewUrl!.isNotEmpty &&
        !list.contains(previewUrl)) {
      list.add(previewUrl!);
    }
    if (thumbnailUrl != null &&
        thumbnailUrl!.isNotEmpty &&
        !list.contains(thumbnailUrl)) {
      list.add(thumbnailUrl!);
    }
    return list;
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    String? imgUrl;
    String? thumbUrl;
    String? prevUrl;

    if (json['image'] is Map<String, dynamic>) {
      final img = json['image'] as Map<String, dynamic>;
      imgUrl = img['url'] as String?;
      thumbUrl = img['thumbnail'] as String?;
      prevUrl = img['preview'] as String?;
    } else if (json['image'] is String) {
      imgUrl = json['image'] as String;
    }

    final cats = <CategoryModel>[];
    if (json['categories'] is List) {
      for (final c in json['categories'] as List) {
        if (c is Map<String, dynamic>) {
          cats.add(CategoryModel.fromJson(c));
        }
      }
    }

    final tgs = <TagModel>[];
    if (json['tags'] is List) {
      for (final t in json['tags'] as List) {
        if (t is Map<String, dynamic>) {
          tgs.add(TagModel.fromJson(t));
        }
      }
    }

    return ProductModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      price: json['price'] as num? ?? 0,
      imageUrl: imgUrl,
      thumbnailUrl: thumbUrl,
      previewUrl: prevUrl,
      categories: cats,
      tags: tgs,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      'price': price,
      if (imageUrl != null)
        'image': {
          'url': imageUrl,
          'thumbnail': thumbnailUrl,
          'preview': previewUrl,
        },
      'categories': categories.map((c) => c.toJson()).toList(),
      'tags': tags.map((t) => t.toJson()).toList(),
      if (createdAt != null) 'created_at': createdAt,
    };
  }
}
