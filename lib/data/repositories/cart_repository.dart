import '../../core/storage/cart_storage_service.dart';
import '../models/cart_item_model.dart';

class CartRepository {
  final CartStorageService cartStorageService;

  CartRepository({required this.cartStorageService});

  List<CartItemModel> getCartItems() {
    final rawList = cartStorageService.getCartItems();
    return rawList.map((map) => CartItemModel.fromJson(map)).toList();
  }

  Future<void> saveCartItems(List<CartItemModel> items) async {
    final rawList = items.map((item) => item.toJson()).toList();
    await cartStorageService.saveCartItems(rawList);
  }

  Future<void> clearCart() async {
    await cartStorageService.clearCart();
  }
}
