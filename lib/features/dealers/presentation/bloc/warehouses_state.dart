part of 'warehouses_bloc.dart';

sealed class WarehousesState extends Equatable {
  const WarehousesState();

  @override
  List<Object?> get props => [];
}

final class WarehousesLoading extends WarehousesState {
  const WarehousesLoading();
}

final class WarehousesLoaded extends WarehousesState {
  const WarehousesLoaded({
    required this.dealer,
    required this.warehouses,
    this.searchQuery = '',
    this.meta,
    this.isRefreshing = false,
    this.isLoadingMore = false,
  });

  final DealerModel dealer;
  final List<WarehouseModel> warehouses;
  final String searchQuery;
  final PaginationMeta? meta;
  final bool isRefreshing;
  final bool isLoadingMore;

  bool get hasMore =>
      meta != null && meta!.currentPage < meta!.lastPage;

  WarehousesLoaded copyWith({
    DealerModel? dealer,
    List<WarehouseModel>? warehouses,
    String? searchQuery,
    PaginationMeta? meta,
    bool? isRefreshing,
    bool? isLoadingMore,
  }) =>
      WarehousesLoaded(
        dealer: dealer ?? this.dealer,
        warehouses: warehouses ?? this.warehouses,
        searchQuery: searchQuery ?? this.searchQuery,
        meta: meta ?? this.meta,
        isRefreshing: isRefreshing ?? this.isRefreshing,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );

  @override
  List<Object?> get props => [
        dealer,
        warehouses,
        searchQuery,
        meta,
        isRefreshing,
        isLoadingMore,
      ];
}

final class WarehousesError extends WarehousesState {
  const WarehousesError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
