import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sement_market_customer/core/di/injection.dart';
import 'package:sement_market_customer/core/utils/api_error.dart';
import 'package:sement_market_customer/features/dealers/data/models/paginated_dealers_response.dart';
import 'package:sement_market_customer/features/orders/data/models/order_model.dart';
import 'package:sement_market_customer/features/orders/data/orders_api.dart';

part 'orders_event.dart';
part 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  OrdersBloc({OrdersApi? api})
      : _api = api ?? getIt<OrdersApi>(),
        super(const OrdersInitial()) {
    on<OrdersLoad>(_onLoad);
    on<OrdersLoadMore>(_onLoadMore);
    add(const OrdersLoad());
  }

  final OrdersApi _api;

  Future<void> _onLoad(OrdersLoad event, Emitter<OrdersState> emit) async {
    if (state is OrdersLoaded) {
      emit((state as OrdersLoaded).copyWith(isRefreshing: true));
    } else {
      emit(const OrdersLoading());
    }

    try {
      final res = await _api.getOrders(page: 1);
      emit(OrdersLoaded(
        orders: res.data,
        meta: res.meta,
      ));
    } catch (e) {
      emit(OrdersError(parseApiError(e)));
    }
  }

  Future<void> _onLoadMore(
      OrdersLoadMore event, Emitter<OrdersState> emit) async {
    if (state is! OrdersLoaded) return;
    final s = state as OrdersLoaded;
    if (!s.hasMore || s.isLoadingMore) return;

    emit(s.copyWith(isLoadingMore: true));

    try {
      final nextPage = (s.meta?.currentPage ?? 1) + 1;
      final res = await _api.getOrders(page: nextPage);
      emit(OrdersLoaded(
        orders: [...s.orders, ...res.data],
        meta: res.meta,
      ));
    } catch (e) {
      emit(s.copyWith(isLoadingMore: false));
    }
  }

  Future<void> refresh() async {
    final completer = Completer<void>();
    final sub = stream
        .where((s) => s is OrdersLoaded || s is OrdersError)
        .listen((_) => completer.complete(), cancelOnError: true);
    add(const OrdersLoad());
    try {
      await completer.future.timeout(const Duration(seconds: 30));
    } finally {
      await sub.cancel();
    }
  }
}
