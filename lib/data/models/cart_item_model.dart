class CartItemModel {
  final int productId;
  final String productName;
  final num unitPrice;
  final String? imageUrl;
  final int quantity;

  const CartItemModel({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    this.imageUrl,
    this.quantity = 1,
  });

  num get lineTotal => unitPrice * quantity;

  CartItemModel copyWith({
    int? productId,
    String? productName,
    num? unitPrice,
    String? imageUrl,
    int? quantity,
  }) {
    return CartItemModel(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      unitPrice: unitPrice ?? this.unitPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
    );
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: json['product_id'] as int? ?? json['id'] as int? ?? 0,
      productName:
          json['product_name'] as String? ?? json['name'] as String? ?? '',
      unitPrice: json['unit_price'] as num? ?? json['price'] as num? ?? 0,
      imageUrl:
          json['image_url'] as String? ??
          (json['image'] is Map
              ? (json['image'] as Map)['url'] as String?
              : null),
      quantity: json['quantity'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'unit_price': unitPrice,
      'image_url': imageUrl,
      'quantity': quantity,
    };
  }
}
