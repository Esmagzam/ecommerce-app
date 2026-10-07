import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/failures.dart';
import '../../data/models/category_model.dart';
import '../../data/models/product_model.dart';
import 'core_providers.dart';

class HomeState {
  final List<CategoryModel> categories;
  final List<ProductModel> newProducts;
  final bool isLoading;
  final Failure? error;

  const HomeState({
    this.categories = const [],
    this.newProducts = const [],
    this.isLoading = false,
    this.error,
  });

  HomeState copyWith({
    List<CategoryModel>? categories,
    List<ProductModel>? newProducts,
    bool? isLoading,
    Failure? error,
    bool clearError = false,
  }) {
    return HomeState(
      categories: categories ?? this.categories,
      newProducts: newProducts ?? this.newProducts,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() {
    state = const HomeState(isLoading: true);
    loadHomeData();
    return state;
  }

  Future<void> loadHomeData() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final productRepo = ref.read(productRepositoryProvider);

    try {
      final categoriesFuture = productRepo.getCategories();
      final productsFuture = productRepo.getProducts(sort: 'newest', perPage: 10);

      final results = await Future.wait([categoriesFuture, productsFuture]);

      final categories = results[0] as List<CategoryModel>;
      final productsPagination = results[1] as dynamic;

      state = state.copyWith(
        categories: categories,
        newProducts: (productsPagination.data as List).cast<ProductModel>(),
        isLoading: false,
        clearError: true,
      );
    } on Failure catch (f) {
      state = state.copyWith(isLoading: false, error: f);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ServerFailure(message: e.toString()),
      );
    }
  }

  Future<void> refresh() async {
    await loadHomeData();
  }
}

final homeProvider = NotifierProvider<HomeNotifier, HomeState>(() {
  return HomeNotifier();
});
