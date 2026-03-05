import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/cart_item_model.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  static const String _cartKey = 'cached_cart_items';

  CartBloc() : super(const CartState()) {
    on<CartItemsLoaded>(_onItemsLoaded);
    on<AddToCart>(_onAddToCart);
    on<UpdateCartItemQuantity>(_onUpdateQuantity);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<ClearCart>(_onClearCart);
    
    add(CartItemsLoaded());
  }

  Future<void> _onItemsLoaded(CartItemsLoaded event, Emitter<CartState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_cartKey);
      if (jsonStr != null) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        final items = decoded.map((e) => CartItemModel.fromJson(e)).toList();
        emit(state.copyWith(items: items, isLoading: false));
      } else {
        emit(state.copyWith(items: [], isLoading: false));
      }
    } catch (_) {
      emit(state.copyWith(items: [], isLoading: false));
    }
  }

  Future<void> _onAddToCart(AddToCart event, Emitter<CartState> emit) async {
    final currentItems = List<CartItemModel>.from(state.items);
    final index = currentItems.indexWhere((i) => i.product.id == event.item.product.id);

    if (index != -1) {
      final existing = currentItems[index];
      currentItems[index] = existing.copyWith(
        quantity: existing.quantity + event.item.quantity,
      );
    } else {
      currentItems.add(event.item);
    }

    emit(state.copyWith(items: currentItems));
    await _saveToStorage(currentItems);
  }

  Future<void> _onUpdateQuantity(UpdateCartItemQuantity event, Emitter<CartState> emit) async {
    final currentItems = List<CartItemModel>.from(state.items);
    final index = currentItems.indexWhere((i) => i.product.id == event.productId);

    if (index != -1) {
      if (event.quantity <= 0) {
        currentItems.removeAt(index);
      } else {
        currentItems[index] = currentItems[index].copyWith(quantity: event.quantity);
      }
      emit(state.copyWith(items: currentItems));
      await _saveToStorage(currentItems);
    }
  }

  Future<void> _onRemoveFromCart(RemoveFromCart event, Emitter<CartState> emit) async {
    final currentItems = List<CartItemModel>.from(state.items);
    currentItems.removeWhere((i) => i.product.id == event.productId);
    emit(state.copyWith(items: currentItems));
    await _saveToStorage(currentItems);
  }

  Future<void> _onClearCart(ClearCart event, Emitter<CartState> emit) async {
    List<CartItemModel> items;
    if (event.warehouseId != null) {
      items = state.items.where((i) => i.warehouseId != event.warehouseId).toList();
    } else {
      items = [];
    }
    emit(state.copyWith(items: items));
    await _saveToStorage(items);
  }

  Future<void> _saveToStorage(List<CartItemModel> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonStr = jsonEncode(items.map((i) => i.toJson()).toList());
      await prefs.setString(_cartKey, jsonStr);
    } catch (_) {}
  }
}
