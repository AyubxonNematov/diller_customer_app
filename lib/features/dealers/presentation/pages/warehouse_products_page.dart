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
import 'package:sement_market_customer/features/dealers/presentation/widgets/Products/product_details_modal.dart';
import 'package:sement_market_customer/features/dealers/presentation/widgets/Products/products_filter_modal.dart';
import 'package:sement_market_customer/features/dealers/presentation/widgets/Products/products_search_bar.dart';
import 'package:sement_market_customer/features/dealers/presentation/widgets/Products/quantity_selection_bottom_sheet.dart';
import 'package:sement_market_customer/core/widgets/detail_page_header.dart';
import 'package:sement_market_customer/core/widgets/success_notification.dart';
import 'package:sement_market_customer/features/dealers/presentation/widgets/Products/products_list.dart';
import 'package:sement_market_customer/features/dealers/presentation/widgets/Products/products_loading_view.dart';

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
                  return const ProductsLoadingView();
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
                  if (state.isRefreshing) {
                    return const ProductsLoadingView();
                  }
                  if (state.products.isEmpty) {
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
                  return ProductsList(
                    products: state.products,
                    onRefresh: _onRefresh,
                    onLoadMore: () => context
                        .read<ProductsBloc>()
                        .add(const ProductsLoadMore()),
                    onProductTap: _showProductDetails,
                    onAddToCart: _showQuantitySheet,
                    hasMore: state.hasMore,
                    isLoadingMore: state.isLoadingMore,
                    scrollController: _scrollController,
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

  void _showProductDetails(ProductModel product) {
    ProductDetailsModal.show(
      context,
      product: product,
      onAddToCart: () => _showQuantitySheet(product),
    );
  }

  void _showQuantitySheet(ProductModel product) {
    final cartState = context.read<CartBloc>().state;
    final existingItem = cartState.items.where((item) => item.product.id == product.id).firstOrNull;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuantitySelectionBottomSheet(
        product: product,
        initialQuantity: existingItem?.quantity ?? 0,
        onConfirm: (quantity) {
          if (existingItem != null) {
            context.read<CartBloc>().add(
                  UpdateCartItemQuantity(
                    productId: product.id,
                    quantity: quantity,
                  ),
                );
          } else {
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
          }
          Navigator.pop(context);
          SuccessNotification.show(
            context,
            title: existingItem != null ? 'SAVAT YANGILANDI' : 'SAVATGA QO\'SHILDI',
            message: '$quantity ${product.unitName ?? 'qop'} ${product.name}',
          );
        },
      ),
    );
  }

}
