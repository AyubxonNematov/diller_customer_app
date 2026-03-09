part of 'orders_bloc.dart';

abstract class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => [];
}

class OrdersInitial extends OrdersState {
  const OrdersInitial();
}

class OrdersLoading extends OrdersState {
  const OrdersLoading();
}

class OrdersLoaded extends OrdersState {
  const OrdersLoaded({
    required this.orders,
    this.meta,
    this.isLoadingMore = false,
    this.isRefreshing = false,
  });

  final List<OrderModel> orders;
  final PaginationMeta? meta;
  final bool isLoadingMore;
  final bool isRefreshing;

  bool get hasMore => meta != null && meta!.currentPage < meta!.lastPage;

  OrdersLoaded copyWith({
    List<OrderModel>? orders,
    PaginationMeta? meta,
    bool? isLoadingMore,
    bool? isRefreshing,
  }) {
    return OrdersLoaded(
      orders: orders ?? this.orders,
      meta: meta ?? this.meta,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [orders, meta, isLoadingMore, isRefreshing];
}

class OrdersError extends OrdersState {
  const OrdersError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
