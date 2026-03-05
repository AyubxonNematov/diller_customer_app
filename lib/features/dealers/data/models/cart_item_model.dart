import 'package:equatable/equatable.dart';
import 'product_model.dart';

class CartItemModel extends Equatable {
  const CartItemModel({
    required this.product,
    required this.quantity,
    required this.warehouseId,
    this.warehouseName,
  });

  final ProductModel product;
  final int quantity;
  final int warehouseId;
  final String? warehouseName;

  double get totalPrice {
    final priceNum = double.tryParse(product.price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
    return priceNum * quantity;
  }

  double get totalEarnings {
    final earningsNum = double.tryParse(product.earningsPerUnit?.replaceAll(RegExp(r'[^\d.]'), '') ?? '0') ?? 0.0;
    return earningsNum * quantity;
  }

  CartItemModel copyWith({
    ProductModel? product,
    int? quantity,
    int? warehouseId,
    String? warehouseName,
  }) {
    return CartItemModel(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      warehouseId: warehouseId ?? this.warehouseId,
      warehouseName: warehouseName ?? this.warehouseName,
    );
  }

  @override
  List<Object?> get props => [product, quantity, warehouseId, warehouseName];

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
      'warehouse_id': warehouseId,
      'warehouse_name': warehouseName,
    };
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      warehouseId: json['warehouse_id'] as int,
      warehouseName: json['warehouse_name'] as String?,
    );
  }
}
