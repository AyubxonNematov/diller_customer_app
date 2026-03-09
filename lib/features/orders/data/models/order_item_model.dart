import 'package:equatable/equatable.dart';
import 'package:sement_market_customer/features/dealers/data/models/product_model.dart';

class OrderItemModel extends Equatable {
  const OrderItemModel({
    required this.id,
    required this.productId,
    this.unitId,
    required this.quantity,
    required this.price,
    this.earnings,
    this.product,
    this.unitName,
  });

  final int id;
  final int productId;
  final int? unitId;
  final String quantity;
  final String price;
  final String? earnings;
  final ProductModel? product;
  final String? unitName;

  double get totalPrice {
    final q = double.tryParse(quantity) ?? 0;
    final p = double.tryParse(price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
    return q * p;
  }

  double get totalEarnings {
    final q = double.tryParse(quantity) ?? 0;
    final e =
        double.tryParse(earnings?.replaceAll(RegExp(r'[^\d.]'), '') ?? '0') ??
            0;
    return q * e;
  }

  @override
  List<Object?> get props =>
      [id, productId, unitId, quantity, price, earnings, product, unitName];

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      unitId: json['unit_id'] as int?,
      quantity: (json['quantity'] ?? 0).toString(),
      price: (json['price'] ?? 0).toString(),
      earnings: json['earnings']?.toString(),
      product: json['product'] != null
          ? ProductModel.fromJson(
              (json['product'] as Map).cast<String, dynamic>())
          : null,
      unitName: json['unit_name']?.toString(),
    );
  }
}
