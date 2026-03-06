import 'package:flutter/material.dart';
import 'package:sement_market_customer/core/theme/app_theme.dart';
import 'package:sement_market_customer/features/dealers/data/models/product_model.dart';
import 'package:sement_market_customer/features/dealers/presentation/widgets/Products/product_card.dart';

class ProductsList extends StatelessWidget {
  const ProductsList({
    super.key,
    required this.products,
    required this.onRefresh,
    required this.onLoadMore,
    required this.onProductTap,
    required this.onAddToCart,
    required this.hasMore,
    required this.isLoadingMore,
    this.scrollController,
  });

  final List<ProductModel> products;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;
  final Function(ProductModel) onProductTap;
  final Function(ProductModel) onAddToCart;
  final bool hasMore;
  final bool isLoadingMore;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.darkNavy,
      child: ListView.separated(
        controller: scrollController,
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: 16 +
              (hasMore ? 60 : 0) +
              MediaQuery.of(context).padding.bottom,
        ),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: products.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= products.length) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              onLoadMore();
            });
            return isLoadingMore
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.darkNavy,
                      ),
                    ),
                  )
                : const SizedBox.shrink();
          }
          final product = products[index];
          return ProductCard(
            key: ValueKey(product.id),
            product: product,
            onTap: () => onProductTap(product),
            onAddToCart: () => onAddToCart(product),
          );
        },
      ),
    );
  }
}
