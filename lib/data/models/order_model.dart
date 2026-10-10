class OrderItemModel {
  final int id;
  final int productId;
  final String productName;
  final String? imageUrl;
  final num unitPrice;
  final int quantity;
  final num lineTotal;

  const OrderItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    this.imageUrl,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    String? imgUrl;
    if (json['image'] is Map) {
      imgUrl =
          (json['image'] as Map)['url'] as String? ??
          (json['image'] as Map)['thumbnail'] as String?;
    } else if (json['image'] is String) {
      imgUrl = json['image'] as String;
    } else if (json['image_url'] is String) {
      imgUrl = json['image_url'] as String;
    }

    return OrderItemModel(
      id: json['id'] as int? ?? 0,
      productId: json['product_id'] as int? ?? 0,
      productName: json['product_name'] as String? ?? '',
      imageUrl: imgUrl,
      unitPrice: json['unit_price'] as num? ?? 0,
      quantity: json['quantity'] as int? ?? 1,
      lineTotal: json['line_total'] as num? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'image_url': imageUrl,
      'unit_price': unitPrice,
      'quantity': quantity,
      'line_total': lineTotal,
    };
  }
}

class OrderModel {
  final int id;
  final String number;
  final String status;
  final String statusLabel;
  final num total;
  final String customerName;
  final String customerPhone;
  final String shippingAddress;
  final String? note;
  final List<OrderItemModel> items;
  final String? cancelledAt;
  final String? createdAt;

  const OrderModel({
    required this.id,
    required this.number,
    required this.status,
    required this.statusLabel,
    required this.total,
    required this.customerName,
    required this.customerPhone,
    required this.shippingAddress,
    this.note,
    this.items = const [],
    this.cancelledAt,
    this.createdAt,
  });

  bool get isCancelled =>
      status.toLowerCase() == 'cancelled' || cancelledAt != null;
  bool get canBeCancelled =>
      status.toLowerCase() == 'pending' && cancelledAt == null;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final itemsList = <OrderItemModel>[];
    if (rawItems is List) {
      for (final it in rawItems) {
        if (it is Map<String, dynamic>) {
          itemsList.add(OrderItemModel.fromJson(it));
        }
      }
    }

    return OrderModel(
      id: json['id'] as int? ?? 0,
      number: json['number'] as String? ?? '',
      status: json['status'] as String? ?? '',
      statusLabel: json['status_label'] as String? ?? '',
      total: json['total'] as num? ?? 0,
      customerName: json['customer_name'] as String? ?? '',
      customerPhone: json['customer_phone'] as String? ?? '',
      shippingAddress: json['shipping_address'] as String? ?? '',
      note: json['note'] as String?,
      items: itemsList,
      cancelledAt: json['cancelled_at'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  OrderModel copyWith({
    int? id,
    String? number,
    String? status,
    String? statusLabel,
    num? total,
    String? customerName,
    String? customerPhone,
    String? shippingAddress,
    String? note,
    List<OrderItemModel>? items,
    String? cancelledAt,
    String? createdAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      number: number ?? this.number,
      status: status ?? this.status,
      statusLabel: statusLabel ?? this.statusLabel,
      total: total ?? this.total,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      note: note ?? this.note,
      items: items ?? this.items,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'status': status,
      'status_label': statusLabel,
      'total': total,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'shipping_address': shippingAddress,
      if (note != null) 'note': note,
      'items': items.map((e) => e.toJson()).toList(),
      'cancelled_at': cancelledAt,
      'created_at': createdAt,
    };
  }
}
