import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/debouncer.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../providers/product_list_provider.dart';
import 'widgets/product_card.dart';
import 'widgets/product_filter_bottom_sheet.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _debouncer = Debouncer(delay: const Duration(milliseconds: 500));

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(productListProvider.notifier).loadMore();
    }
  }

  void _showFilterBottomSheet() {
    final state = ref.read(productListProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ProductFilterBottomSheet(
        categories: state.availableCategories,
        tags: state.availableTags,
        initialCategoryId: state.selectedCategoryId,
        initialTagId: state.selectedTagId,
        initialMinPrice: state.minPrice,
        initialMaxPrice: state.maxPrice,
        onApply: ({categoryId, tagId, minPrice, maxPrice}) {
          ref.read(productListProvider.notifier).applyFilters(
                categoryId: categoryId,
                tagId: tagId,
                minPrice: minPrice,
                maxPrice: maxPrice,
              );
        },
        onReset: () {
          ref.read(productListProvider.notifier).resetFilters();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Бүтээгдэхүүн'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                // Search Field
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Бүтээгдэхүүн хайх...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                ref.read(productListProvider.notifier).setSearch('');
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      fillColor: theme.cardColor,
                    ),
                    onChanged: (value) {
                      _debouncer.run(() {
                        ref.read(productListProvider.notifier).setSearch(value);
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),

                // Filter Button with Badge
                Badge(
                  isLabelVisible: state.hasActiveFilters,
                  child: Container(
                    decoration: BoxDecoration(
                      color: state.hasActiveFilters
                          ? AppColors.primary
                          : theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: state.hasActiveFilters
                            ? AppColors.primary
                            : theme.dividerColor,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.tune_rounded,
                        color: state.hasActiveFilters
                            ? Colors.white
                            : theme.colorScheme.onSurface,
                        size: 20,
                      ),
                      tooltip: 'Шүүлтүүр',
                      onPressed: _showFilterBottomSheet,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Sort Bar & Active Filter Info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              border: Border(
                bottom: BorderSide(color: theme.dividerColor, width: 0.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Нийт: ${state.products.length} бараа',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                PopupMenuButton<String>(
                  initialValue: state.sortBy,
                  onSelected: (val) {
                    ref.read(productListProvider.notifier).setSort(val);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'newest',
                      child: Text('Шинэ нь эхэндээ'),
                    ),
                    const PopupMenuItem(
                      value: 'price_asc',
                      child: Text('Үнэ: багаас их рүү'),
                    ),
                    const PopupMenuItem(
                      value: 'price_desc',
                      child: Text('Үнэ: ихээс бага руу'),
                    ),
                    const PopupMenuItem(
                      value: 'name',
                      child: Text('Нэрээр (А-Я)'),
                    ),
                  ],
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.sort_rounded, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        _getSortLabel(state.sortBy),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Active filter indicator if any
          if (state.hasActiveFilters)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              color: AppColors.primary.withValues(alpha: 0.05),
              child: Row(
                children: [
                  const Icon(Icons.filter_alt, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'Шүүлтүүр идэвхтэй байна',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        ref.read(productListProvider.notifier).resetFilters(),
                    child: const Text(
                      'Цэвэрлэх',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Product List Grid
          Expanded(
            child: state.isLoading
                ? const LoadingIndicator(message: 'Бүтээгдэхүүн уншиж байна...')
                : state.error != null
                    ? ErrorView(
                        error: state.error,
                        onRetry: () =>
                            ref.read(productListProvider.notifier).refresh(),
                      )
                    : state.products.isEmpty
                        ? EmptyView(
                            icon: Icons.search_off_rounded,
                            title: 'Бүтээгдэхүүн олдсонгүй',
                            subtitle:
                                'Хайлтын үг эсвэл шүүлтүүрийг өөрчилж үзнэ үү.',
                            actionButtonText: state.hasActiveFilters
                                ? 'Шүүлтүүр цэвэрлэх'
                                : null,
                            onActionPressed: state.hasActiveFilters
                                ? () => ref
                                    .read(productListProvider.notifier)
                                    .resetFilters()
                                : null,
                          )
                        : RefreshIndicator(
                            onRefresh: () => ref
                                .read(productListProvider.notifier)
                                .refresh(),
                            child: GridView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.68,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: state.products.length +
                                  (state.isLoadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == state.products.length) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2.5),
                                    ),
                                  );
                                }
                                final product = state.products[index];
                                return ProductCard(product: product);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  String _getSortLabel(String sort) {
    switch (sort) {
      case 'price_asc':
        return 'Үнэ өсөх';
      case 'price_desc':
        return 'Үнэ буурах';
      case 'name':
        return 'Нэрээр';
      case 'newest':
      default:
        return 'Шинэ нь';
    }
  }
}
