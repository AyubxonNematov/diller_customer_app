part of 'dealers_bloc.dart';

sealed class DealersEvent extends Equatable {
  const DealersEvent();

  @override
  List<Object?> get props => [];
}

final class DealersLoad extends DealersEvent {
  const DealersLoad();
}

final class DealersSearchChanged extends DealersEvent {
  const DealersSearchChanged(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

final class DealersSearchApply extends DealersEvent {
  const DealersSearchApply(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

final class DealersFiltersApplied extends DealersEvent {
  const DealersFiltersApplied({
    this.categoryId,
    this.regionId,
  });

  final int? categoryId;
  final int? regionId;

  @override
  List<Object?> get props => [categoryId, regionId];
}

final class DealersLoadMore extends DealersEvent {
  const DealersLoadMore();
}
