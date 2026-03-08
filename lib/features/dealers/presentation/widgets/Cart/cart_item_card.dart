import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sement_market_customer/core/theme/app_theme.dart';
import 'package:sement_market_customer/features/dealers/presentation/bloc/cart_bloc.dart';
import 'package:sement_market_customer/features/dealers/data/models/cart_item_model.dart';

class CartItemCard extends StatelessWidget {
  const CartItemCard({
    super.key,
    required this.item,
  });

  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  item.product.firstImage ?? '',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                      color: AppColors.background,
                      child: const Icon(Icons.image)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkNavy),
                    ),
                    Text(
                      '${_formatPrice(item.product.price)} sum / ${item.product.unitName ?? 'qop'}',
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.darkNavy,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => context
                    .read<CartBloc>()
                    .add(RemoveFromCart(item.product.id)),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                style:
                    IconButton.styleFrom(backgroundColor: Colors.red.shade50),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 0.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildQuantityController(context),
              Text(
                '${_formatPrice(item.totalPrice.toStringAsFixed(0))} sum',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkNavy),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _quickAdjustItemButton(context, -500),
              const SizedBox(width: 8),
              _quickAdjustItemButton(context, -50),
              const SizedBox(width: 8),
              _quickAdjustItemButton(context, 50),
              const SizedBox(width: 8),
              _quickAdjustItemButton(context, 500),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityController(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => context.read<CartBloc>().add(
                UpdateCartItemQuantity(
                    productId: item.product.id, quantity: item.quantity - 1)),
            icon: const Icon(Icons.remove, size: 18, color: Color(0xFF1E2D3D)),
          ),
          Text(
            item.quantity.toString(),
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E2D3D)),
          ),
          IconButton(
            onPressed: () => context.read<CartBloc>().add(
                UpdateCartItemQuantity(
                    productId: item.product.id, quantity: item.quantity + 1)),
            icon: const Icon(Icons.add, size: 18, color: Color(0xFF1E2D3D)),
          ),
        ],
      ),
    );
  }

  Widget _quickAdjustItemButton(BuildContext context, int delta) {
    final bool isNeg = delta < 0;
    return Expanded(
      child: InkWell(
        onTap: () => context.read<CartBloc>().add(UpdateCartItemQuantity(
            productId: item.product.id, quantity: item.quantity + delta)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isNeg ? Colors.red[50] : Colors.green[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: isNeg ? Colors.red[100]! : Colors.green[100]!),
          ),
          child: Text(
            (delta > 0 ? '+$delta' : '$delta'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: isNeg ? Colors.red[700] : Colors.green[700],
            ),
          ),
        ),
      ),
    );
  }

  String _formatPrice(String price) {
    try {
      final value =
          double.tryParse(price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
      return value.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
    } catch (_) {
      return price;
    }
  }
}
