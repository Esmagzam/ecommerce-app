import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/api_service.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../models/pagination_model.dart';

class OrderRepository {
  final ApiService apiService;

  OrderRepository({required this.apiService});

  Future<PaginationModel<OrderModel>> getOrders({int page = 1}) async {
    try {
      final response = await apiService.get(
        '/shop/orders',
        queryParameters: {'page': page},
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return PaginationModel<OrderModel>.fromJson(
          data,
          (itemJson) => OrderModel.fromJson(itemJson),
        );
      }
      return PaginationModel<OrderModel>(
        data: [],
        currentPage: page,
        lastPage: page,
        total: 0,
        perPage: 10,
      );
    } on ServerException catch (e) {
      throw ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
        fieldErrors: e.fieldErrors,
      );
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  Future<OrderModel> createOrder({
    required String customerName,
    required String customerPhone,
    required String shippingAddress,
    String? note,
    required List<CartItemModel> items,
  }) async {
    try {
      final payload = {
        'customer_name': customerName.trim(),
        'customer_phone': customerPhone.trim(),
        'shipping_address': shippingAddress.trim(),
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
        'items': items
            .map((e) => {
                  'product_id': e.productId,
                  'quantity': e.quantity,
                })
            .toList(),
      };

      final response = await apiService.post(
        '/shop/orders',
        data: payload,
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
        return OrderModel.fromJson(data['data'] as Map<String, dynamic>);
      }
      throw const ServerFailure(message: 'Захиалга үүсгэхэд алдаа гарлаа.');
    } on ServerException catch (e) {
      throw ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
        fieldErrors: e.fieldErrors,
      );
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  Future<OrderModel> getOrderDetail(int id) async {
    try {
      final response = await apiService.get('/shop/orders/$id');
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
        return OrderModel.fromJson(data['data'] as Map<String, dynamic>);
      }
      throw const ServerFailure(message: 'Захиалгын мэдээлэл олдсонгүй.');
    } on ServerException catch (e) {
      throw ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
        fieldErrors: e.fieldErrors,
      );
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }

  Future<OrderModel> cancelOrder(int id) async {
    try {
      final response = await apiService.post('/shop/orders/$id/cancel');
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is Map<String, dynamic>) {
        return OrderModel.fromJson(data['data'] as Map<String, dynamic>);
      }
      throw const ServerFailure(message: 'Захиалга цуцлахад алдаа гарлаа.');
    } on ServerException catch (e) {
      throw ServerFailure(
        message: e.message,
        statusCode: e.statusCode,
        fieldErrors: e.fieldErrors,
      );
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }
}
