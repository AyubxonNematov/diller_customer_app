import 'package:equatable/equatable.dart';
import 'product_model.dart';

/// A cart item combining product data from API with local quantity.
class CartItemModel extends Equatable {
  const CartItemModel({
    required this.product,
    required this.quantity,
  });

  final ProductModel product;
  final int quantity;

  double get totalPrice {
    final priceNum =
        double.tryParse(product.price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
    return priceNum * quantity;
  }

  double get totalEarnings {
    final earningsNum = double.tryParse(
            product.earningsPerUnit?.replaceAll(RegExp(r'[^\d.]'), '') ??
                '0') ??
        0.0;
    return earningsNum * quantity;
  }

  CartItemModel copyWith({
    ProductModel? product,
    int? quantity,
  }) {
    return CartItemModel(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [product, quantity];
}
