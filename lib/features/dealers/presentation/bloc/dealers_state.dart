part of 'dealers_bloc.dart';

sealed class DealersState extends Equatable {
  const DealersState();

  @override
  List<Object?> get props => [];
}

final class DealersInitial extends DealersState {
  const DealersInitial();
}

final class DealersLoading extends DealersState {
  const DealersLoading();
}

final class DealersLoaded extends DealersState {
  const DealersLoaded({
    required this.dealers,
    this.selectedCategoryId,
    this.selectedRegionId,
    this.searchQuery = '',
    this.location,
    this.meta,
    this.isRefreshing = false,
    this.isLoadingMore = false,
  });

  final List<DealerModel> dealers;
  final int? selectedCategoryId;
  final int? selectedRegionId;
  final String searchQuery;
  final String? location;
  final PaginationMeta? meta;
  final bool isRefreshing;
  final bool isLoadingMore;

  bool get hasMore =>
      meta != null && meta!.currentPage < meta!.lastPage;

  int get activeFiltersCount =>
      (selectedCategoryId != null ? 1 : 0) + (selectedRegionId != null ? 1 : 0);

  DealersLoaded copyWith({
    List<DealerModel>? dealers,
    int? selectedCategoryId,
    bool clearCategoryId = false,
    int? selectedRegionId,
    bool clearRegionId = false,
    String? searchQuery,
    String? location,
    PaginationMeta? meta,
    bool? isRefreshing,
    bool? isLoadingMore,
  }) =>
      DealersLoaded(
        dealers: dealers ?? this.dealers,
        selectedCategoryId: clearCategoryId
            ? null
            : (selectedCategoryId ?? this.selectedCategoryId),
        selectedRegionId: clearRegionId
            ? null
            : (selectedRegionId ?? this.selectedRegionId),
        searchQuery: searchQuery ?? this.searchQuery,
        location: location ?? this.location,
        meta: meta ?? this.meta,
        isRefreshing: isRefreshing ?? this.isRefreshing,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );

  @override
  List<Object?> get props => [
        dealers,
        selectedCategoryId,
        selectedRegionId,
        searchQuery,
        location,
        meta,
        isRefreshing,
        isLoadingMore,
      ];
}

final class DealersError extends DealersState {
  const DealersError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
