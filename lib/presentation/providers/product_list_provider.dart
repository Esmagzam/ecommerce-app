import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/failures.dart';
import '../../data/models/category_model.dart';
import '../../data/models/product_model.dart';
import '../../data/models/tag_model.dart';
import 'core_providers.dart';

class ProductListState {
  final String search;
  final int? selectedCategoryId;
  final int? selectedTagId;
  final num? minPrice;
  final num? maxPrice;
  final String sortBy;
  final List<CategoryModel> availableCategories;
  final List<TagModel> availableTags;
  final List<ProductModel> products;
  final int currentPage;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final Failure? error;

  const ProductListState({
    this.search = '',
    this.selectedCategoryId,
    this.selectedTagId,
    this.minPrice,
    this.maxPrice,
    this.sortBy = 'newest',
    this.availableCategories = const [],
    this.availableTags = const [],
    this.products = const [],
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
  });

  bool get hasActiveFilters =>
      selectedCategoryId != null ||
      selectedTagId != null ||
      (minPrice != null && minPrice! > 0) ||
      (maxPrice != null && maxPrice! > 0);

  ProductListState copyWith({
    String? search,
    int? selectedCategoryId,
    bool clearCategory = false,
    int? selectedTagId,
    bool clearTag = false,
    num? minPrice,
    bool clearMinPrice = false,
    num? maxPrice,
    bool clearMaxPrice = false,
    String? sortBy,
    List<CategoryModel>? availableCategories,
    List<TagModel>? availableTags,
    List<ProductModel>? products,
    int? currentPage,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    Failure? error,
    bool clearError = false,
  }) {
    return ProductListState(
      search: search ?? this.search,
      selectedCategoryId: clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
      selectedTagId: clearTag ? null : (selectedTagId ?? this.selectedTagId),
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      sortBy: sortBy ?? this.sortBy,
      availableCategories: availableCategories ?? this.availableCategories,
      availableTags: availableTags ?? this.availableTags,
      products: products ?? this.products,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ProductListNotifier extends Notifier<ProductListState> {
  @override
  ProductListState build() {
    state = const ProductListState(isLoading: true);
    loadInitial();
    _loadMetadata();
    return state;
  }

  Future<void> _loadMetadata() async {
    final productRepo = ref.read(productRepositoryProvider);
    try {
      final catsFuture = productRepo.getCategories();
      final tagsFuture = productRepo.getTags();
      final results = await Future.wait([catsFuture, tagsFuture]);
      state = state.copyWith(
        availableCategories: results[0] as List<CategoryModel>,
        availableTags: results[1] as List<TagModel>,
      );
    } catch (_) {}
  }

  Future<void> loadInitial() async {
    state = state.copyWith(
      isLoading: true,
      currentPage: 1,
      products: [],
      hasMore: true,
      clearError: true,
    );

    final productRepo = ref.read(productRepositoryProvider);

    try {
      final pagination = await productRepo.getProducts(
        search: state.search,
        categoryId: state.selectedCategoryId,
        tagId: state.selectedTagId,
        minPrice: state.minPrice,
        maxPrice: state.maxPrice,
        sort: state.sortBy,
        page: 1,
        perPage: 12,
      );

      state = state.copyWith(
        products: pagination.data,
        currentPage: 1,
        hasMore: pagination.hasMore,
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

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.currentPage + 1;
    final productRepo = ref.read(productRepositoryProvider);

    try {
      final pagination = await productRepo.getProducts(
        search: state.search,
        categoryId: state.selectedCategoryId,
        tagId: state.selectedTagId,
        minPrice: state.minPrice,
        maxPrice: state.maxPrice,
        sort: state.sortBy,
        page: nextPage,
        perPage: 12,
      );

      state = state.copyWith(
        products: [...state.products, ...pagination.data],
        currentPage: nextPage,
        hasMore: pagination.hasMore,
        isLoadingMore: false,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void setSearch(String query) {
    if (state.search == query) return;
    state = state.copyWith(search: query);
    loadInitial();
  }

  void setSort(String sort) {
    if (state.sortBy == sort) return;
    state = state.copyWith(sortBy: sort);
    loadInitial();
  }

  void setCategory(int? categoryId) {
    state = state.copyWith(
      selectedCategoryId: categoryId,
      clearCategory: categoryId == null,
    );
    loadInitial();
  }

  void applyFilters({
    int? categoryId,
    int? tagId,
    num? minPrice,
    num? maxPrice,
  }) {
    state = state.copyWith(
      selectedCategoryId: categoryId,
      clearCategory: categoryId == null,
      selectedTagId: tagId,
      clearTag: tagId == null,
      minPrice: minPrice,
      clearMinPrice: minPrice == null,
      maxPrice: maxPrice,
      clearMaxPrice: maxPrice == null,
    );
    loadInitial();
  }

  void resetFilters() {
    state = state.copyWith(
      clearCategory: true,
      clearTag: true,
      clearMinPrice: true,
      clearMaxPrice: true,
    );
    loadInitial();
  }

  Future<void> refresh() async {
    await loadInitial();
  }
}

final productListProvider =
    NotifierProvider<ProductListNotifier, ProductListState>(() {
  return ProductListNotifier();
});
