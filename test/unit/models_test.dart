import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce_app/data/models/category_model.dart';
import 'package:ecommerce_app/data/models/order_model.dart';
import 'package:ecommerce_app/data/models/product_model.dart';
import 'package:ecommerce_app/data/models/user_model.dart';

void main() {
  group('Models Serialization Tests', () {
    test('UserModel fromJson and toJson', () {
      final json = {
        'id': 43,
        'name': 'Test User',
        'email': 'test@example.com',
        'is_admin': false,
        'created_at': '2026-10-08T02:00:00Z',
      };

      final user = UserModel.fromJson(json);
      expect(user.id, 43);
      expect(user.name, 'Test User');
      expect(user.email, 'test@example.com');
      expect(user.isAdmin, false);
      expect(user.toJson()['email'], 'test@example.com');
    });

    test('CategoryModel parses nested image map', () {
      final json = {
        'id': 6,
        'name': 'Гоо сайхан',
        'description': 'Арьс арчилгаа',
        'image': {
          'url': 'https://job.sutainbuyant.com/storage/36/placeholder.png',
          'thumbnail':
              'https://job.sutainbuyant.com/storage/36/conversions/thumb.jpg',
        },
        'products_count': 15,
      };

      final cat = CategoryModel.fromJson(json);
      expect(cat.id, 6);
      expect(cat.name, 'Гоо сайхан');
      expect(cat.imageUrl, contains('placeholder.png'));
      expect(cat.thumbnailUrl, contains('thumb.jpg'));
      expect(cat.productsCount, 15);
    });

    test('ProductModel parses tags, categories, image and gallery', () {
      final json = {
        'id': 36,
        'name': 'Уруулын будаг',
        'price': 29000,
        'image': {
          'url': 'https://job.sutainbuyant.com/storage/42/placeholder.png',
          'thumbnail':
              'https://job.sutainbuyant.com/storage/42/conversions/thumb.jpg',
          'preview':
              'https://job.sutainbuyant.com/storage/42/conversions/prev.jpg',
        },
        'categories': [
          {'id': 6, 'name': 'Гоо сайхан'},
        ],
        'tags': [
          {'id': 1, 'name': 'Шинэ'},
        ],
      };

      final product = ProductModel.fromJson(json);
      expect(product.id, 36);
      expect(product.name, 'Уруулын будаг');
      expect(product.price, 29000);
      expect(product.categories.length, 1);
      expect(product.tags.length, 1);
      expect(product.imageGallery.length, 3);
    });

    test('OrderModel parses items and status', () {
      final json = {
        'id': 142,
        'number': 'SO261008-I3N1RN',
        'status': 'pending',
        'status_label': 'Хүлээгдэж буй',
        'total': 93000,
        'customer_name': 'Бат',
        'customer_phone': '99112233',
        'shipping_address': 'УБ, СБД, 1-р хороо',
        'items': [
          {
            'id': 345,
            'product_id': 36,
            'product_name': 'Уруулын будаг',
            'unit_price': 29000,
            'quantity': 2,
            'line_total': 58000,
          },
        ],
      };

      final order = OrderModel.fromJson(json);
      expect(order.id, 142);
      expect(order.number, 'SO261008-I3N1RN');
      expect(order.total, 93000);
      expect(order.items.length, 1);
      expect(order.items.first.lineTotal, 58000);
      expect(order.canBeCancelled, isTrue);
      expect(order.isCancelled, isFalse);
    });
  });
}
