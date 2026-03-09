part of 'cart_bloc.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

/// Load cart entries from local storage.
class CartItemsLoaded extends CartEvent {}

/// Fetch fresh warehouse + product data from API.
class LoadCartData extends CartEvent {}

/// Add a product to cart (lightweight: just IDs + quantity).
class AddToCart extends CartEvent {
  final int productId;
  final int warehouseId;
  final int quantity;

  const AddToCart({
    required this.productId,
    required this.warehouseId,
    this.quantity = 1,
  });

  @override
  List<Object?> get props => [productId, warehouseId, quantity];
}

class UpdateCartItemQuantity extends CartEvent {
  final int productId;
  final int quantity;
  const UpdateCartItemQuantity(
      {required this.productId, required this.quantity});

  @override
  List<Object?> get props => [productId, quantity];
}

class RemoveFromCart extends CartEvent {
  final int productId;
  const RemoveFromCart(this.productId);

  @override
  List<Object?> get props => [productId];
}

class ClearCart extends CartEvent {
  final int? warehouseId;
  const ClearCart({this.warehouseId});

  @override
  List<Object?> get props => [warehouseId];
}

class PlaceOrder extends CartEvent {
  final int warehouseId;
  final String deliveryType; // 'pickup', 'delivery', 'free_delivery'
  const PlaceOrder({required this.warehouseId, required this.deliveryType});

  @override
  List<Object?> get props => [warehouseId, deliveryType];
}
