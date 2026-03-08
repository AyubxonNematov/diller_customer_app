import 'package:equatable/equatable.dart';
import 'package:sement_market_customer/features/dealers/data/models/cart_item_model.dart';
import 'package:sement_market_customer/features/dealers/data/models/warehouse_model.dart';

/// Combined warehouse info + resolved cart items from API.
class CartWarehouseData extends Equatable {
  const CartWarehouseData({
    required this.warehouse,
    required this.items,
  });

  final WarehouseModel warehouse;
  final List<CartItemModel> items;

  double get totalPrice =>
      items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get totalEarnings =>
      items.fold(0.0, (sum, item) => sum + item.totalEarnings);

  double get freeDeliveryThreshold {
    final raw = warehouse.freeDeliveryThreshold;
    if (raw == null) return 0;
    return double.tryParse(raw) ?? 0;
  }

  @override
  List<Object?> get props => [warehouse, items];
}
