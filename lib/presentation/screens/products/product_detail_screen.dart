import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_detail_provider.dart';
import 'widgets/product_card.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final int productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _selectedQuantity = 1;
  int _activeImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(productDetailProvider(widget.productId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Бүтээгдэхүүний дэлгэрэнгүй'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            tooltip: 'Сагс үзэх',
            onPressed: () => context.go('/cart'),
          ),
        ],
      ),
      body: detailAsync.when(
        loading: () => const LoadingIndicator(message: 'Бүтээгдэхүүн уншиж байна...'),
        error: (error, stack) => ErrorView(
          error: error,
          onRetry: () => ref.refresh(productDetailProvider(widget.productId)),
        ),
        data: (result) {
          final product = result.product;
          final related = result.related;
          final images = product.imageGallery;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Carousel
                      if (images.isNotEmpty)
                        SStackCarousel(
                          pageController: _pageController,
                          images: images,
                          activeImageIndex: _activeImageIndex,
                          onPageChanged: (index) {
                            setState(() => _activeImageIndex = index);
                          },
                        )
                      else
                        Container(
                          height: 300,
                          color: Colors.grey.withValues(alpha: 0.1),
                          child: const Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                          ),
                        ),

                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tags & Categories
                            if (product.categories.isNotEmpty ||
                                product.tags.isNotEmpty)
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  ...product.categories.map((c) => Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          c.name,
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      )),
                                  ...product.tags.map((t) => Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.secondary
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          t.name,
                                          style: const TextStyle(
                                            color: AppColors.secondary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      )),
                                ],
                              ),
                            const SizedBox(height: 12),

                            // Product Title
                            Text(
                              product.name,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Price
                            Text(
                              Formatters.formatCurrency(product.price),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 20),

                            const Divider(),
                            const SizedBox(height: 12),

                            // Description
                            const Text(
                              'Тайлбар',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product.description != null &&
                                      product.description!.isNotEmpty
                                  ? product.description!
                                  : 'Тайлбар оруулаагүй байна.',
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Related Products
                            if (related.isNotEmpty) ...[
                              const Divider(),
                              const SizedBox(height: 12),
                              const Text(
                                'Холбоотой бүтээгдэхүүн',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 14),
                              SizedBox(
                                height: 250,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: related.length,
                                  itemBuilder: (context, index) {
                                    final relProduct = related[index];
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(right: 12.0),
                                      child: SizedBox(
                                        width: 170,
                                        child: ProductCard(product: relProduct),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Sticky Add to Cart Action Bar
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  border: Border(
                    top: BorderSide(color: theme.dividerColor, width: 1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      // Quantity Selector
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.dividerColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 18),
                              onPressed: _selectedQuantity > 1
                                  ? () {
                                      setState(() {
                                        _selectedQuantity--;
                                      });
                                    }
                                  : null,
                            ),
                            Text(
                              '$_selectedQuantity',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 18),
                              onPressed: () {
                                setState(() {
                                  _selectedQuantity++;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Add to Cart Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ref.read(cartProvider.notifier).addToCart(
                                  product,
                                  quantity: _selectedQuantity,
                                );
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    '${product.name} ($_selectedQuantity ширхэг) сагсанд нэмэгдлээ'),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                action: SnackBarAction(
                                  label: 'Сагс үзэх',
                                  onPressed: () => context.go('/cart'),
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_shopping_cart_rounded),
                          label: const Text('Сагсанд нэмэх'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class SStackCarousel extends StatelessWidget {
  final PageController pageController;
  final List<String> images;
  final int activeImageIndex;
  final ValueChanged<int> onPageChanged;

  const SStackCarousel({
    super.key,
    required this.pageController,
    required this.images,
    required this.activeImageIndex,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: Stack(
        children: [
          PageView.builder(
            controller: pageController,
            itemCount: images.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              final imgUrl = images[index];
              return CachedNetworkImage(
                imageUrl: imgUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey.withValues(alpha: 0.1),
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.withValues(alpha: 0.1),
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    size: 48,
                    color: Colors.grey,
                  ),
                ),
              );
            },
          ),
          if (images.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (index) {
                  final isActive = index == activeImageIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : Colors.white70,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}
