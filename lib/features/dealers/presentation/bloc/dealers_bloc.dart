import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sement_market_customer/core/di/injection.dart';
import 'package:sement_market_customer/core/utils/api_error.dart';
import 'package:sement_market_customer/core/utils/location_helper.dart';
import 'package:sement_market_customer/features/dealers/data/dealers_api.dart';
import 'package:sement_market_customer/features/dealers/data/models/dealer_model.dart';
import 'package:sement_market_customer/features/dealers/data/models/paginated_dealers_response.dart';

part 'dealers_event.dart';
part 'dealers_state.dart';

class DealersBloc extends Bloc<DealersEvent, DealersState> {
  DealersBloc({DealersApi? api})
      : _api = api ?? getIt<DealersApi>(),
        super(const DealersLoading()) {
    on<DealersLoad>(_onLoad);
    on<DealersSearchChanged>(_onSearchChanged);
    on<DealersSearchApply>(_onSearchApply);
    on<DealersFiltersApplied>(_onFiltersApplied);
    on<DealersLoadMore>(_onLoadMore);
    add(const DealersLoad());
  }

  final DealersApi _api;
  String? _location;
  Timer? _searchDebounce;

  static const _searchDebounceDuration = Duration(milliseconds: 400);

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }

  Future<void> _onLoad(DealersLoad event, Emitter<DealersState> emit) async {
    if (state is DealersLoaded) {
      emit((state as DealersLoaded).copyWith(isRefreshing: true));
    } else {
      emit(const DealersLoading());
    }

    if (_location == null) {
      unawaited(LocationHelper.getCurrentLocation().then((loc) {
        if (loc != null) _location = loc;
      }));
    }

    await _loadDealers(emit);
  }

  Future<void> _loadDealers(
    Emitter<DealersState> emit, {
    int? categoryId,
    int? regionId,
    String? search,
    int page = 1,
    bool appendDealers = false,
    bool replaceFilters = false,
  }) async {
    try {
      final prev = state is DealersLoaded ? state as DealersLoaded : null;
      final effectiveCategoryId =
          replaceFilters ? categoryId : (categoryId ?? prev?.selectedCategoryId);
      final effectiveRegionId =
          replaceFilters ? regionId : (regionId ?? prev?.selectedRegionId);

      final dealersRes = await _api.getDealers(
        categoryId: effectiveCategoryId,
        regionId: effectiveRegionId,
        location: _location,
        search: search ?? prev?.searchQuery,
        page: page,
      );

      final prevDealers =
          appendDealers && prev != null ? prev.dealers : <DealerModel>[];
      final dealers =
          page > 1 ? [...prevDealers, ...dealersRes.data] : dealersRes.data;

      emit(DealersLoaded(
        dealers: dealers,
        selectedCategoryId: effectiveCategoryId,
        selectedRegionId: effectiveRegionId,
        searchQuery: search ?? prev?.searchQuery ?? '',
        location: _location,
        meta: dealersRes.meta,
      ));
    } catch (e) {
      emit(DealersError(parseApiError(e)));
    }
  }

  void _onSearchChanged(
    DealersSearchChanged event,
    Emitter<DealersState> emit,
  ) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(_searchDebounceDuration, () {
      add(DealersSearchApply(event.query));
    });
  }

  Future<void> _onSearchApply(
    DealersSearchApply event,
    Emitter<DealersState> emit,
  ) async {
    if (state is! DealersLoaded) return;
    final s = state as DealersLoaded;
    await _loadDealers(
      emit,
      search: event.query,
      categoryId: s.selectedCategoryId,
      regionId: s.selectedRegionId,
    );
  }

  Future<void> _onFiltersApplied(
    DealersFiltersApplied event,
    Emitter<DealersState> emit,
  ) async {
    if (state is! DealersLoaded) return;
    final s = state as DealersLoaded;
    await _loadDealers(
      emit,
      categoryId: event.categoryId,
      regionId: event.regionId,
      search: s.searchQuery,
      replaceFilters: true,
    );
  }

  Future<void> refresh() async {
    final completer = Completer<void>();
    final sub = stream
        .where((s) => s is DealersLoaded || s is DealersError)
        .listen((_) => completer.complete(), cancelOnError: true);
    add(const DealersLoad());
    try {
      await completer.future.timeout(const Duration(seconds: 30));
    } finally {
      await sub.cancel();
    }
  }

  Future<void> _onLoadMore(
    DealersLoadMore event,
    Emitter<DealersState> emit,
  ) async {
    if (state is! DealersLoaded) return;
    final s = state as DealersLoaded;
    if (!s.hasMore || s.isLoadingMore) return;
    emit(s.copyWith(isLoadingMore: true));
    await _loadDealers(
      emit,
      categoryId: s.selectedCategoryId,
      regionId: s.selectedRegionId,
      search: s.searchQuery,
      page: (s.meta?.currentPage ?? 1) + 1,
      appendDealers: true,
    );
  }
}
