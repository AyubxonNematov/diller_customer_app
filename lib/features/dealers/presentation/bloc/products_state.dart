part of 'products_bloc.dart';

sealed class ProductsState extends Equatable {
  const ProductsState();

  @override
  List<Object?> get props => [];
}

final class ProductsLoading extends ProductsState {
  const ProductsLoading();
}

final class ProductsLoaded extends ProductsState {
  const ProductsLoaded({
    required this.warehouse,
    required this.products,
    this.searchQuery = '',
    this.selectedBrandId,
    this.sortBy = '-created_at',
    this.meta,
    this.isRefreshing = false,
    this.isLoadingMore = false,
  });

  final WarehouseModel warehouse;
  final List<ProductModel> products;
  final String searchQuery;
  final int? selectedBrandId;
  final String sortBy;
  final PaginationMeta? meta;
  final bool isRefreshing;
  final bool isLoadingMore;

  bool get hasMore => meta != null && meta!.currentPage < meta!.lastPage;

  int get activeFiltersCount => selectedBrandId != null ? 1 : 0;

  ProductsLoaded copyWith({
    WarehouseModel? warehouse,
    List<ProductModel>? products,
    String? searchQuery,
    int? selectedBrandId,
    String? sortBy,
    PaginationMeta? meta,
    bool? isRefreshing,
    bool? isLoadingMore,
  }) =>
      ProductsLoaded(
        warehouse: warehouse ?? this.warehouse,
        products: products ?? this.products,
        searchQuery: searchQuery ?? this.searchQuery,
        selectedBrandId: selectedBrandId ?? this.selectedBrandId,
        sortBy: sortBy ?? this.sortBy,
        meta: meta ?? this.meta,
        isRefreshing: isRefreshing ?? this.isRefreshing,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );

  @override
  List<Object?> get props => [
        warehouse,
        products,
        searchQuery,
        selectedBrandId,
        sortBy,
        meta,
        isRefreshing,
        isLoadingMore,
      ];
}

final class ProductsError extends ProductsState {
  const ProductsError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
