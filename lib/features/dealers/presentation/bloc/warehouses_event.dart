part of 'warehouses_bloc.dart';

sealed class WarehousesEvent extends Equatable {
  const WarehousesEvent();

  @override
  List<Object?> get props => [];
}

final class WarehousesLoad extends WarehousesEvent {
  const WarehousesLoad();
}

final class WarehousesSearchChanged extends WarehousesEvent {
  const WarehousesSearchChanged(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

final class WarehousesSearchApply extends WarehousesEvent {
  const WarehousesSearchApply(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

final class WarehousesLoadMore extends WarehousesEvent {
  const WarehousesLoadMore();
}
