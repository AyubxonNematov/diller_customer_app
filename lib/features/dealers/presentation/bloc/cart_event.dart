part of 'cart_bloc.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class CartItemsLoaded extends CartEvent {}

class AddToCart extends CartEvent {
  final CartItemModel item;
  const AddToCart(this.item);

  @override
  List<Object?> get props => [item];
}

class UpdateCartItemQuantity extends CartEvent {
  final int productId;
  final int quantity;
  const UpdateCartItemQuantity({required this.productId, required this.quantity});

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
