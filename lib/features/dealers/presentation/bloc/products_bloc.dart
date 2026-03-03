import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sement_market_customer/core/di/injection.dart';
import 'package:sement_market_customer/core/utils/api_error.dart';
import 'package:sement_market_customer/features/dealers/data/dealers_api.dart';
import 'package:sement_market_customer/features/dealers/data/models/paginated_dealers_response.dart';
import 'package:sement_market_customer/features/dealers/data/models/product_model.dart';
import 'package:sement_market_customer/features/dealers/data/models/warehouse_model.dart';

part 'products_event.dart';
part 'products_state.dart';

/// Bloc for warehouse products: search, brand filter, sort, pagination.
class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  ProductsBloc({
    required WarehouseModel warehouse,
    DealersApi? api,
  })  : _warehouse = warehouse,
        _api = api ?? getIt<DealersApi>(),
        super(const ProductsInitial()) {
    on<ProductsLoad>(_onLoad);
    on<ProductsSearchChanged>(_onSearchChanged);
    on<ProductsSearchApply>(_onSearchApply);
    on<ProductsFiltersApplied>(_onFiltersApplied);
    on<ProductsLoadMore>(_onLoadMore);
  }

  final WarehouseModel _warehouse;
  final DealersApi _api;
  Timer? _searchDebounce;

  static const _searchDebounceDuration = Duration(milliseconds: 400);

  WarehouseModel get warehouse => _warehouse;

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }

  Future<void> _onLoad(
    ProductsLoad event,
    Emitter<ProductsState> emit,
  ) async {
    if (state is ProductsLoaded) {
      emit((state as ProductsLoaded).copyWith(isRefreshing: true));
    } else {
      emit(const ProductsLoading());
    }
    await _loadProducts(emit);
  }

  Future<void> _loadProducts(
    Emitter<ProductsState> emit, {
    String? search,
    int? brandId,
    String? sort,
    int page = 1,
    bool appendProducts = false,
    bool replaceFilters = false,
  }) async {
    try {
      final prev = state is ProductsLoaded ? state as ProductsLoaded : null;
      final effectiveBrandId =
          replaceFilters ? brandId : (brandId ?? prev?.selectedBrandId);
      final effectiveSort = replaceFilters ? sort : (sort ?? prev?.sortBy);

      final productsRes = await _api.getProducts(
        warehouseId: _warehouse.id,
        search: search ?? prev?.searchQuery,
        brandId: effectiveBrandId,
        sort: effectiveSort,
        page: page,
      );

      final prevProducts =
          appendProducts && prev != null ? prev.products : <ProductModel>[];
      final products =
          page > 1 ? [...prevProducts, ...productsRes.data] : productsRes.data;

      emit(ProductsLoaded(
        warehouse: _warehouse,
        products: products,
        searchQuery: search ?? prev?.searchQuery ?? '',
        selectedBrandId: effectiveBrandId,
        sortBy: effectiveSort ?? '-created_at',
        meta: productsRes.meta,
        isRefreshing: false,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(ProductsError(parseApiError(e)));
    }
  }

  void _onSearchChanged(
    ProductsSearchChanged event,
    Emitter<ProductsState> emit,
  ) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(_searchDebounceDuration, () {
      add(ProductsSearchApply(event.query));
    });
  }

  Future<void> _onSearchApply(
    ProductsSearchApply event,
    Emitter<ProductsState> emit,
  ) async {
    if (state is! ProductsLoaded) return;
    final s = state as ProductsLoaded;
    await _loadProducts(
      emit,
      search: event.query,
      brandId: s.selectedBrandId,
    );
  }

  Future<void> _onFiltersApplied(
    ProductsFiltersApplied event,
    Emitter<ProductsState> emit,
  ) async {
    if (state is! ProductsLoaded) return;
    final s = state as ProductsLoaded;
    await _loadProducts(
      emit,
      search: s.searchQuery,
      brandId: event.brandId,
      replaceFilters: true,
    );
  }

  Future<void> _onLoadMore(
    ProductsLoadMore event,
    Emitter<ProductsState> emit,
  ) async {
    if (state is! ProductsLoaded) return;
    final s = state as ProductsLoaded;
    if (!s.hasMore || s.isLoadingMore) return;
    emit(s.copyWith(isLoadingMore: true));
    await _loadProducts(
      emit,
      search: s.searchQuery,
      brandId: s.selectedBrandId,
      sort: s.sortBy,
      page: (s.meta?.currentPage ?? 1) + 1,
      appendProducts: true,
    );
  }

  Future<void> refresh() async {
    final completer = Completer<void>();
    final sub = stream
        .where((s) => s is ProductsLoaded || s is ProductsError)
        .listen((_) => completer.complete(), cancelOnError: true);
    add(const ProductsLoad());
    try {
      await completer.future.timeout(const Duration(seconds: 30));
    } finally {
      await sub.cancel();
    }
  }
}
