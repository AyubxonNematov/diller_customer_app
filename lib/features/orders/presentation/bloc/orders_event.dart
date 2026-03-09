part of 'orders_bloc.dart';

abstract class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => [];
}

class OrdersLoad extends OrdersEvent {
  const OrdersLoad();
}

class OrdersLoadMore extends OrdersEvent {
  const OrdersLoadMore();
}
