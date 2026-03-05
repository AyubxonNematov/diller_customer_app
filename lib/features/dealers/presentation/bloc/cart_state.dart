part of 'cart_bloc.dart';

class CartState extends Equatable {
  const CartState({
    this.items = const [],
    this.isLoading = false,
  });

  final List<CartItemModel> items;
  final bool isLoading;

  double get totalAmount => items.fold(0, (sum, item) => sum + item.totalPrice);
  double get totalEarnings => items.fold(0, (sum, item) => sum + item.totalEarnings);

  Map<int, List<CartItemModel>> get groupedItems {
    final Map<int, List<CartItemModel>> groups = {};
    for (final item in items) {
      if (!groups.containsKey(item.warehouseId)) {
        groups[item.warehouseId] = [];
      }
      groups[item.warehouseId]!.add(item);
    }
    return groups;
  }

  CartState copyWith({
    List<CartItemModel>? items,
    bool? isLoading,
  }) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [items, isLoading];
}
