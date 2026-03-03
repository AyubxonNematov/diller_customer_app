part of 'products_bloc.dart';

sealed class ProductsEvent extends Equatable {
  const ProductsEvent();

  @override
  List<Object?> get props => [];
}

final class ProductsLoad extends ProductsEvent {
  const ProductsLoad();
}

final class ProductsSearchChanged extends ProductsEvent {
  const ProductsSearchChanged(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

final class ProductsSearchApply extends ProductsEvent {
  const ProductsSearchApply(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

final class ProductsFiltersApplied extends ProductsEvent {
  const ProductsFiltersApplied({this.brandId});
  final int? brandId;

  @override
  List<Object?> get props => [brandId];
}

final class ProductsLoadMore extends ProductsEvent {
  const ProductsLoadMore();
}
