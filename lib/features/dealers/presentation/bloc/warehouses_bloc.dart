import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sement_market_customer/core/di/injection.dart';
import 'package:sement_market_customer/core/utils/api_error.dart';
import 'package:sement_market_customer/core/utils/location_helper.dart';
import 'package:sement_market_customer/features/dealers/data/dealers_api.dart';
import 'package:sement_market_customer/features/dealers/data/models/dealer_model.dart';
import 'package:sement_market_customer/features/dealers/data/models/paginated_dealers_response.dart';
import 'package:sement_market_customer/features/dealers/data/models/warehouse_model.dart';

part 'warehouses_event.dart';
part 'warehouses_state.dart';

/// Bloc for dealer warehouses list: search, location (always if available), pagination.
class WarehousesBloc extends Bloc<WarehousesEvent, WarehousesState> {
  WarehousesBloc({
    required DealerModel dealer,
    DealersApi? api,
  })  : _dealer = dealer,
        _api = api ?? getIt<DealersApi>(),
        super(const WarehousesLoading()) {
    on<WarehousesLoad>(_onLoad);
    on<WarehousesSearchChanged>(_onSearchChanged);
    on<WarehousesSearchApply>(_onSearchApply);
    on<WarehousesLoadMore>(_onLoadMore);
    add(const WarehousesLoad());
  }

  final DealerModel _dealer;
  final DealersApi _api;
  String? _location;
  Timer? _searchDebounce;

  static const _searchDebounceDuration = Duration(milliseconds: 400);

  DealerModel get dealer => _dealer;

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }

  Future<void> _onLoad(
    WarehousesLoad event,
    Emitter<WarehousesState> emit,
  ) async {
    if (state is WarehousesLoaded) {
      emit((state as WarehousesLoaded).copyWith(isRefreshing: true));
    } else {
      emit(const WarehousesLoading());
    }

    // Don't wait for location to start loading data.
    // If we have it cached, use it. Otherwise, fetch it in background for next refresh/page.
    if (_location == null) {
      unawaited(LocationHelper.getCurrentLocation().then((loc) {
        if (loc != null) _location = loc;
      }));
    }

    await _loadWarehouses(emit);
  }

  Future<void> _loadWarehouses(
    Emitter<WarehousesState> emit, {
    String? search,
    int page = 1,
    bool appendWarehouses = false,
  }) async {
    try {
      final prev = state is WarehousesLoaded ? state as WarehousesLoaded : null;
      final warehousesRes = await _api.getWarehouses(
        dealerId: _dealer.id,
        search: search ?? prev?.searchQuery,
        location: _location,
        page: page,
      );

      final prevWarehouses =
          appendWarehouses && prev != null ? prev.warehouses : <WarehouseModel>[];
      final warehouses = page > 1
          ? [...prevWarehouses, ...warehousesRes.data]
          : warehousesRes.data;

      emit(WarehousesLoaded(
        dealer: _dealer,
        warehouses: warehouses,
        searchQuery: search ?? prev?.searchQuery ?? '',
        meta: warehousesRes.meta,
        isRefreshing: false,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(WarehousesError(parseApiError(e)));
    }
  }

  void _onSearchChanged(
    WarehousesSearchChanged event,
    Emitter<WarehousesState> emit,
  ) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(_searchDebounceDuration, () {
      add(WarehousesSearchApply(event.query));
    });
  }

  Future<void> _onSearchApply(
    WarehousesSearchApply event,
    Emitter<WarehousesState> emit,
  ) async {
    await _loadWarehouses(emit, search: event.query);
  }

  Future<void> _onLoadMore(
    WarehousesLoadMore event,
    Emitter<WarehousesState> emit,
  ) async {
    if (state is! WarehousesLoaded) return;
    final s = state as WarehousesLoaded;
    if (!s.hasMore || s.isLoadingMore) return;
    emit(s.copyWith(isLoadingMore: true));
    await _loadWarehouses(
      emit,
      search: s.searchQuery,
      page: (s.meta?.currentPage ?? 1) + 1,
      appendWarehouses: true,
    );
  }

  Future<void> refresh() async {
    final completer = Completer<void>();
    final sub = stream
        .where((s) => s is WarehousesLoaded || s is WarehousesError)
        .listen((_) => completer.complete(), cancelOnError: true);
    add(const WarehousesLoad());
    try {
      await completer.future.timeout(const Duration(seconds: 30));
    } finally {
      await sub.cancel();
    }
  }
}
