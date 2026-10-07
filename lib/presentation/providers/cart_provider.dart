import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/product_model.dart';
import 'core_providers.dart';

class CartState {
  final List<CartItemModel> items;

  const CartState({this.items = const []});

  num get totalAmount =>
      items.fold<num>(0, (sum, item) => sum + item.lineTotal);

  int get totalItemCount =>
      items.fold<int>(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => items.isEmpty;

  CartItemModel? getItem(int productId) {
    try {
      return items.firstWhere((element) => element.productId == productId);
    } catch (_) {
      return null;
    }
  }

  CartState copyWith({List<CartItemModel>? items}) {
    return CartState(items: items ?? this.items);
  }
}

class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() {
    _loadFromStorage();
    return const CartState();
  }

  void _loadFromStorage() {
    try {
      final cartRepo = ref.read(cartRepositoryProvider);
      final storedItems = cartRepo.getCartItems();
      state = CartState(items: storedItems);
    } catch (_) {}
  }

  Future<void> _persist() async {
    try {
      final cartRepo = ref.read(cartRepositoryProvider);
      await cartRepo.saveCartItems(state.items);
    } catch (_) {}
  }

  Future<void> addToCart(ProductModel product, {int quantity = 1}) async {
    final existingIndex =
        state.items.indexWhere((element) => element.productId == product.id);

    List<CartItemModel> newItems;
    if (existingIndex >= 0) {
      final existing = state.items[existingIndex];
      final updated = existing.copyWith(quantity: existing.quantity + quantity);
      newItems = List<CartItemModel>.from(state.items);
      newItems[existingIndex] = updated;
    } else {
      final newItem = CartItemModel(
        productId: product.id,
        productName: product.name,
        unitPrice: product.price,
        imageUrl: product.imageUrl ?? product.thumbnailUrl,
        quantity: quantity,
      );
      newItems = [...state.items, newItem];
    }

    state = CartState(items: newItems);
    await _persist();
  }

  Future<void> updateQuantity(int productId, int quantity) async {
    if (quantity <= 0) {
      await removeItem(productId);
      return;
    }

    final newItems = state.items.map((item) {
      if (item.productId == productId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    state = CartState(items: newItems);
    await _persist();
  }

  Future<void> increment(int productId) async {
    final item = state.getItem(productId);
    if (item != null) {
      await updateQuantity(productId, item.quantity + 1);
    }
  }

  Future<void> decrement(int productId) async {
    final item = state.getItem(productId);
    if (item != null) {
      if (item.quantity > 1) {
        await updateQuantity(productId, item.quantity - 1);
      } else {
        await removeItem(productId);
      }
    }
  }

  Future<void> removeItem(int productId) async {
    final newItems =
        state.items.where((element) => element.productId != productId).toList();
    state = CartState(items: newItems);
    await _persist();
  }

  Future<void> clearCart() async {
    state = const CartState(items: []);
    try {
      final cartRepo = ref.read(cartRepositoryProvider);
      await cartRepo.clearCart();
    } catch (_) {}
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(() {
  return CartNotifier();
});
