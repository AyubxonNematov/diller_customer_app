import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sement_market_customer/core/di/injection.dart';
import 'package:sement_market_customer/features/dealers/data/dealers_api.dart';
import 'package:sement_market_customer/features/dealers/data/models/cart_entry.dart';
import 'package:sement_market_customer/features/dealers/data/models/cart_item_model.dart';
import 'package:sement_market_customer/features/dealers/data/models/cart_warehouse_data.dart';
import 'package:sement_market_customer/features/dealers/data/models/product_model.dart';
import 'package:sement_market_customer/features/dealers/data/models/warehouse_model.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  static const String _cartKey = 'cached_cart_entries';

  CartBloc() : super(const CartState()) {
    on<CartItemsLoaded>(_onItemsLoaded);
    on<LoadCartData>(_onLoadCartData);
    on<AddToCart>(_onAddToCart);
    on<UpdateCartItemQuantity>(_onUpdateQuantity);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<ClearCart>(_onClearCart);

    add(CartItemsLoaded());
  }

  final DealersApi _dealersApi = getIt<DealersApi>();

  Future<void> _onItemsLoaded(
      CartItemsLoaded event, Emitter<CartState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_cartKey);
      if (jsonStr != null) {
        final List<dynamic> decoded = jsonDecode(jsonStr);
        final entries = decoded.map((e) => CartEntry.fromJson(e)).toList();
        emit(state.copyWith(entries: entries, isLoading: false));
      } else {
        emit(state.copyWith(entries: [], isLoading: false));
      }
    } catch (_) {
      emit(state.copyWith(entries: [], isLoading: false));
    }

    // Fetch fresh data from API
    add(LoadCartData());
  }

  Future<void> _onLoadCartData(
      LoadCartData event, Emitter<CartState> emit) async {
    if (state.entries.isEmpty) {
      emit(state.copyWith(
        warehouseData: {},
        isLoading: false,
        error: null,
      ));
      return;
    }

    emit(state.copyWith(isLoading: true, error: null));

    try {
      // Group entries by warehouse
      final Map<int, List<CartEntry>> grouped = {};
      for (final entry in state.entries) {
        grouped.putIfAbsent(entry.warehouseId, () => []).add(entry);
      }

      final Map<int, CartWarehouseData> warehouseData = {};

      for (final warehouseId in grouped.keys) {
        final entries = grouped[warehouseId]!;
        final productIds = entries.map((e) => e.productId).toList();

        final response = await _dealersApi.getWarehouseWithProducts(
          warehouseId: warehouseId,
          productIds: productIds,
        );

        final warehouseJson = response['warehouse'] is Map<String, dynamic>
            ? response['warehouse'] as Map<String, dynamic>
            : (response['warehouse'] as Map).cast<String, dynamic>();

        final warehouse = WarehouseModel.fromJson(warehouseJson);

        final productsJson =
            response['products'] is List ? response['products'] as List : [];

        final List<CartItemModel> items = [];
        for (final entry in entries) {
          final productData = productsJson.firstWhere(
            (p) => (p is Map && p['id'] == entry.productId),
            orElse: () => null,
          );
          if (productData != null) {
            final product = ProductModel.fromJson(
              (productData as Map).cast<String, dynamic>(),
            );
            items.add(CartItemModel(
              product: product,
              quantity: entry.quantity,
            ));
          }
        }

        warehouseData[warehouseId] = CartWarehouseData(
          warehouse: warehouse,
          items: items,
        );
      }

      emit(state.copyWith(
        warehouseData: warehouseData,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onAddToCart(AddToCart event, Emitter<CartState> emit) async {
    final currentEntries = List<CartEntry>.from(state.entries);
    final index = currentEntries.indexWhere((e) =>
        e.productId == event.productId && e.warehouseId == event.warehouseId);

    if (index != -1) {
      final existing = currentEntries[index];
      currentEntries[index] = existing.copyWith(
        quantity: existing.quantity + event.quantity,
      );
    } else {
      currentEntries.add(CartEntry(
        productId: event.productId,
        warehouseId: event.warehouseId,
        quantity: event.quantity,
      ));
    }

    emit(state.copyWith(entries: currentEntries));
    await _saveToStorage(currentEntries);
    add(LoadCartData());
  }

  Future<void> _onUpdateQuantity(
      UpdateCartItemQuantity event, Emitter<CartState> emit) async {
    final currentEntries = List<CartEntry>.from(state.entries);
    final index =
        currentEntries.indexWhere((e) => e.productId == event.productId);

    if (index != -1) {
      // Minimum quantity is 1 — item is never auto-removed
      final clampedQuantity = event.quantity < 1 ? 1 : event.quantity;

      currentEntries[index] =
          currentEntries[index].copyWith(quantity: clampedQuantity);

      emit(state.copyWith(entries: currentEntries));
      await _saveToStorage(currentEntries);

      // Update warehouse data in-memory without refetching
      final updatedWarehouseData =
          Map<int, CartWarehouseData>.from(state.warehouseData);
      for (final warehouseId in updatedWarehouseData.keys) {
        final data = updatedWarehouseData[warehouseId]!;
        final updatedItems = data.items.map((item) {
          if (item.product.id == event.productId) {
            return item.copyWith(quantity: clampedQuantity);
          }
          return item;
        }).toList();
        updatedWarehouseData[warehouseId] = CartWarehouseData(
          warehouse: data.warehouse,
          items: updatedItems,
        );
      }
      emit(state.copyWith(warehouseData: updatedWarehouseData));
    }
  }

  Future<void> _onRemoveFromCart(
      RemoveFromCart event, Emitter<CartState> emit) async {
    final currentEntries = List<CartEntry>.from(state.entries);
    currentEntries.removeWhere((e) => e.productId == event.productId);
    emit(state.copyWith(entries: currentEntries));
    await _saveToStorage(currentEntries);

    // Update warehouse data in-memory
    final updatedWarehouseData =
        Map<int, CartWarehouseData>.from(state.warehouseData);
    for (final warehouseId in updatedWarehouseData.keys.toList()) {
      final data = updatedWarehouseData[warehouseId]!;
      final updatedItems = data.items
          .where((item) => item.product.id != event.productId)
          .toList();
      if (updatedItems.isEmpty) {
        updatedWarehouseData.remove(warehouseId);
      } else {
        updatedWarehouseData[warehouseId] = CartWarehouseData(
          warehouse: data.warehouse,
          items: updatedItems,
        );
      }
    }
    emit(state.copyWith(warehouseData: updatedWarehouseData));
  }

  Future<void> _onClearCart(ClearCart event, Emitter<CartState> emit) async {
    List<CartEntry> entries;
    Map<int, CartWarehouseData> warehouseData;

    if (event.warehouseId != null) {
      entries = state.entries
          .where((e) => e.warehouseId != event.warehouseId)
          .toList();
      warehouseData = Map<int, CartWarehouseData>.from(state.warehouseData)
        ..remove(event.warehouseId);
    } else {
      entries = [];
      warehouseData = {};
    }

    emit(state.copyWith(entries: entries, warehouseData: warehouseData));
    await _saveToStorage(entries);
  }

  Future<void> _saveToStorage(List<CartEntry> entries) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonStr =
          jsonEncode(entries.map((e) => e.toJson()).toList());
      await prefs.setString(_cartKey, jsonStr);
    } catch (_) {}
  }
}
