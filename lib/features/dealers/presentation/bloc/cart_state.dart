part of 'cart_bloc.dart';

class CartState extends Equatable {
  const CartState({
    this.entries = const [],
    this.warehouseData = const {},
    this.isLoading = false,
    this.error,
  });

  /// Lightweight entries stored locally (product_id, warehouse_id, quantity).
  final List<CartEntry> entries;

  /// Full warehouse + product data fetched from API, keyed by warehouse ID.
  final Map<int, CartWarehouseData> warehouseData;

  final bool isLoading;
  final String? error;

  /// Total item count across all warehouses (for badge).
  int get totalItemCount => entries.length;

  /// Whether we have loaded warehouse data from API.
  bool get hasData => warehouseData.isNotEmpty;

  /// Get warehouse IDs that have data.
  List<int> get warehouseIds => warehouseData.keys.toList();

  CartState copyWith({
    List<CartEntry>? entries,
    Map<int, CartWarehouseData>? warehouseData,
    bool? isLoading,
    String? error,
  }) {
    return CartState(
      entries: entries ?? this.entries,
      warehouseData: warehouseData ?? this.warehouseData,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [entries, warehouseData, isLoading, error];
}
