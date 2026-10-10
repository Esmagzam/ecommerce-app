import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_service.dart';
import '../../core/storage/cart_storage_service.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/cart_repository.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/repositories/product_repository.dart';

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final cartStorageServiceProvider = Provider<CartStorageService>((ref) {
  return CartStorageService();
});

final apiServiceProvider = Provider<ApiService>((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return ApiService(
    secureStorageService: secureStorage,
    onUnauthorized: () {
      // Токен хүчингүй болох үед: Auth provider чагнах эсвэл interceptor токеныг устгана
    },
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return AuthRepository(
    apiService: apiService,
    secureStorageService: secureStorage,
  );
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ProductRepository(apiService: apiService);
});

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  final cartStorage = ref.watch(cartStorageServiceProvider);
  return CartRepository(cartStorageService: cartStorage);
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return OrderRepository(apiService: apiService);
});
