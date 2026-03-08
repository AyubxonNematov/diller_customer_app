import 'package:equatable/equatable.dart';

/// Lightweight cart entry stored locally in SharedPreferences.
/// Only stores IDs and quantity — all other data is fetched from API.
class CartEntry extends Equatable {
  const CartEntry({
    required this.productId,
    required this.warehouseId,
    required this.quantity,
  });

  final int productId;
  final int warehouseId;
  final int quantity;

  CartEntry copyWith({
    int? productId,
    int? warehouseId,
    int? quantity,
  }) {
    return CartEntry(
      productId: productId ?? this.productId,
      warehouseId: warehouseId ?? this.warehouseId,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'warehouse_id': warehouseId,
      'quantity': quantity,
    };
  }

  factory CartEntry.fromJson(Map<String, dynamic> json) {
    return CartEntry(
      productId: json['product_id'] as int,
      warehouseId: json['warehouse_id'] as int,
      quantity: json['quantity'] as int,
    );
  }

  @override
  List<Object?> get props => [productId, warehouseId, quantity];
}
