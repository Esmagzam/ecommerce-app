import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ecommerce_app/data/models/product_model.dart';
import 'package:ecommerce_app/data/repositories/cart_repository.dart';
import 'package:ecommerce_app/presentation/providers/cart_provider.dart';
import 'package:ecommerce_app/presentation/providers/core_providers.dart';

class MockCartRepository extends Mock implements CartRepository {}

void main() {
  late MockCartRepository mockCartRepo;
  late ProviderContainer container;

  setUp(() {
    mockCartRepo = MockCartRepository();
    when(() => mockCartRepo.getCartItems()).thenReturn([]);
    when(() => mockCartRepo.saveCartItems(any())).thenAnswer((_) async {});
    when(() => mockCartRepo.clearCart()).thenAnswer((_) async {});

    container = ProviderContainer(
      overrides: [
        cartRepositoryProvider.overrideWithValue(mockCartRepo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('CartNotifier Tests', () {
    const testProduct = ProductModel(
      id: 1,
      name: 'Test Product',
      price: 15000,
    );

    test('initial state is empty', () {
      final state = container.read(cartProvider);
      expect(state.isEmpty, isTrue);
      expect(state.totalAmount, 0);
      expect(state.totalItemCount, 0);
    });

    test('addToCart adds new item and calculates totals', () async {
      await container.read(cartProvider.notifier).addToCart(testProduct, quantity: 2);

      final state = container.read(cartProvider);
      expect(state.isEmpty, isFalse);
      expect(state.items.length, 1);
      expect(state.items.first.productId, 1);
      expect(state.items.first.quantity, 2);
      expect(state.totalAmount, 30000);
      expect(state.totalItemCount, 2);
      verify(() => mockCartRepo.saveCartItems(any())).called(1);
    });

    test('addToCart increments quantity for existing item', () async {
      await container.read(cartProvider.notifier).addToCart(testProduct, quantity: 1);
      await container.read(cartProvider.notifier).addToCart(testProduct, quantity: 2);

      final state = container.read(cartProvider);
      expect(state.items.length, 1);
      expect(state.items.first.quantity, 3);
      expect(state.totalAmount, 45000);
    });

    test('increment and decrement update quantity', () async {
      await container.read(cartProvider.notifier).addToCart(testProduct, quantity: 2);

      await container.read(cartProvider.notifier).increment(1);
      expect(container.read(cartProvider).items.first.quantity, 3);

      await container.read(cartProvider.notifier).decrement(1);
      expect(container.read(cartProvider).items.first.quantity, 2);

      // Decrementing down from 1 removes item
      await container.read(cartProvider.notifier).decrement(1);
      expect(container.read(cartProvider).items.first.quantity, 1);

      await container.read(cartProvider.notifier).decrement(1);
      expect(container.read(cartProvider).isEmpty, isTrue);
    });

    test('clearCart empties the cart', () async {
      await container.read(cartProvider.notifier).addToCart(testProduct, quantity: 1);
      expect(container.read(cartProvider).isEmpty, isFalse);

      await container.read(cartProvider.notifier).clearCart();
      expect(container.read(cartProvider).isEmpty, isTrue);
      expect(container.read(cartProvider).totalAmount, 0);
      verify(() => mockCartRepo.clearCart()).called(1);
    });
  });
}
