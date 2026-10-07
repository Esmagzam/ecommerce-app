import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/product_repository.dart';
import 'core_providers.dart';

final productDetailProvider =
    FutureProvider.family<ProductDetailResult, int>((ref, productId) async {
  final productRepo = ref.watch(productRepositoryProvider);
  return await productRepo.getProductDetail(productId);
});
