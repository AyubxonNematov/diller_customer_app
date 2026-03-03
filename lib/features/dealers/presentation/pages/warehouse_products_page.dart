import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sement_market_customer/core/theme/app_theme.dart';
import 'package:sement_market_customer/l10n/app_localizations.dart';
import 'package:sement_market_customer/features/dealers/data/models/warehouse_model.dart';
import 'package:sement_market_customer/features/dealers/presentation/bloc/products_bloc.dart';
import 'package:sement_market_customer/features/dealers/presentation/widgets/dealers_empty_state.dart';
import 'package:sement_market_customer/features/dealers/presentation/widgets/dealers_error_state.dart';
import 'package:sement_market_customer/features/dealers/presentation/widgets/product_card.dart';
import 'package:sement_market_customer/features/dealers/presentation/widgets/products_filter_modal.dart';
import 'package:sement_market_customer/features/dealers/presentation/widgets/products_search_bar.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsBloc>().add(const ProductsLoad());
    });
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
          _WarehouseHeader(
            warehouse: widget.warehouse,
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
                        child: GridView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 8,
                            bottom: 16 +
                                (state.hasMore ? 60 : 0) +
                                MediaQuery.of(context).padding.bottom,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.72,
                          ),
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
                            );
                          },
                        ),
                      ),
                      if (state.isRefreshing)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Material(
                            elevation: 0,
                            color: Colors.white.withValues(alpha: 0.8),
                            child: SafeArea(
                              bottom: false,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.darkNavy,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      AppLocalizations.of(context)!
                                          .dealersLoading,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.grayText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
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

class _WarehouseHeader extends StatelessWidget {
  const _WarehouseHeader({
    required this.warehouse,
    required this.onBack,
  });

  final WarehouseModel warehouse;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.darkNavy,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 4,
        right: 16,
        bottom: 14,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 22,
              ),
              onPressed: onBack,
              style: IconButton.styleFrom(
                minimumSize: const Size(48, 48),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    warehouse.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    warehouse.address,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
