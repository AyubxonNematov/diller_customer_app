import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sement_market_customer/core/theme/app_theme.dart';
import 'package:sement_market_customer/l10n/app_localizations.dart';
import 'package:sement_market_customer/features/dealers/data/models/warehouse_model.dart';
import 'package:sement_market_customer/features/dealers/presentation/bloc/products_bloc.dart';
import 'package:sement_market_customer/features/dealers/presentation/widgets/Dealers/dealers_empty_state.dart';
import 'package:sement_market_customer/features/dealers/presentation/widgets/Dealers/dealers_error_state.dart';
import 'package:sement_market_customer/features/dealers/data/models/product_model.dart';
import 'package:sement_market_customer/features/dealers/data/models/cart_item_model.dart';
import 'package:sement_market_customer/features/dealers/presentation/bloc/cart_bloc.dart';
import 'package:sement_market_customer/features/dealers/presentation/widgets/Products/product_card.dart';
import 'package:sement_market_customer/features/dealers/presentation/widgets/Products/products_filter_modal.dart';
import 'package:sement_market_customer/features/dealers/presentation/widgets/Products/products_search_bar.dart';
import 'package:sement_market_customer/features/dealers/presentation/widgets/Products/quantity_selection_bottom_sheet.dart';
import 'package:sement_market_customer/core/widgets/detail_page_header.dart';
import 'package:sement_market_customer/core/widgets/refreshing_overlay.dart';

class WarehouseProductsPage extends StatefulWidget {
  const WarehouseProductsPage({
    super.key,
    required this.warehouse,
  });

  final WarehouseModel warehouse;

  @override
  State<WarehouseProductsPage> createState() => _WarehouseProductsPageState();
}

class _WarehouseProductsPageState extends State<WarehouseProductsPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await context.read<ProductsBloc>().refresh();
  }

  void _onFilterTap() {
    final bloc = context.read<ProductsBloc>();
    final state = bloc.state;
    if (state is! ProductsLoaded) return;

    ProductsFilterModal.show(
      context,
      warehouse: widget.warehouse,
      currentBrandId: state.selectedBrandId,
      onApply: ({brandId}) {
        bloc.add(ProductsFiltersApplied(brandId: brandId));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          DetailPageHeader(
            title: widget.warehouse.name,
            subtitle: widget.warehouse.address,
            onBack: () => context.pop(),
          ),
          BlocBuilder<ProductsBloc, ProductsState>(
            buildWhen: (p, c) =>
                p is ProductsLoaded != c is ProductsLoaded ||
                (c is ProductsLoaded &&
                    p is ProductsLoaded &&
                    (p.searchQuery != c.searchQuery ||
                        p.activeFiltersCount != c.activeFiltersCount)),
            builder: (context, state) {
              if (state is ProductsLoaded) {
                return ProductsSearchBar(
                  searchQuery: state.searchQuery,
                  activeFiltersCount: state.activeFiltersCount,
                  onChanged: (q) => context
                      .read<ProductsBloc>()
                      .add(ProductsSearchChanged(q)),
                  onFilterTap: _onFilterTap,
                );
              }
              return const SizedBox.shrink();
            },
          ),
          Expanded(
            child: BlocBuilder<ProductsBloc, ProductsState>(
              builder: (context, state) {
                if (state is ProductsLoading) {
                  return _buildSkeleton();
                }
                if (state is ProductsError) {
                  return DealersErrorState(
                    message: state.message,
                    onRetry: () => context
                        .read<ProductsBloc>()
                        .add(const ProductsLoad()),
                  );
                }
                if (state is ProductsLoaded) {
                  if (state.products.isEmpty && !state.isRefreshing) {
                    return DealersEmptyState(
                      emptyTitle:
                          AppLocalizations.of(context)!.productsEmpty,
                      emptyHint:
                          AppLocalizations.of(context)!.productsEmptyHint,
                      hasActiveFilters: state.activeFiltersCount > 0,
                      onRetry: () => context
                          .read<ProductsBloc>()
                          .add(const ProductsLoad()),
                      onClearFilters: state.activeFiltersCount > 0
                          ? () => context.read<ProductsBloc>().add(
                                const ProductsFiltersApplied(brandId: null),
                              )
                          : null,
                    );
                  }
                  return Stack(
                    children: [
                      RefreshIndicator(
                        onRefresh: _onRefresh,
                        color: AppColors.darkNavy,
                        child: ListView.separated(
                          controller: _scrollController,
                          padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 8,
                            bottom: 16 +
                                (state.hasMore ? 60 : 0) +
                                MediaQuery.of(context).padding.bottom,
                          ),
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemCount:
                              state.products.length + (state.hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= state.products.length) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                context
                                    .read<ProductsBloc>()
                                    .add(const ProductsLoadMore());
                              });
                              return state.isLoadingMore
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
                            return ProductCard(
                              key: ValueKey(state.products[index].id),
                              product: state.products[index],
                              onTap: () => _showQuantitySheet(state.products[index]),
                            );
                          },
                        ),
                      ),
                      RefreshingOverlay(
                        isRefreshing: state.isRefreshing,
                        message: AppLocalizations.of(context)!.dealersLoading,
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showQuantitySheet(ProductModel product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuantitySelectionBottomSheet(
        product: product,
        onConfirm: (quantity) {
          context.read<CartBloc>().add(
                AddToCart(
                  CartItemModel(
                    product: product,
                    quantity: quantity,
                    warehouseId: widget.warehouse.id,
                    warehouseName: widget.warehouse.name,
                  ),
                ),
              );
          Navigator.pop(context);
          _showSuccessOverlay(product, quantity);
        },
      ),
    );
  }

  void _showSuccessOverlay(ProductModel product, int quantity) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 10,
        right: 10,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0x33FFFFFF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 12),
                const Text(
                  'SAVATGA QO\'SHILDI',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  '$quantity ${product.unitName ?? 'qop'} ${product.name}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () => overlayEntry.remove());
  }

  Widget _buildSkeleton() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => _ProductCardSkeleton(),
    );
  }
}


class _ProductCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.2,
            child: Container(
              color: AppColors.graySubtle.withValues(alpha: 0.5),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.graySubtle.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: 80,
                  decoration: BoxDecoration(
                    color: AppColors.graySubtle.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 16,
                  width: 70,
                  decoration: BoxDecoration(
                    color: AppColors.graySubtle.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
