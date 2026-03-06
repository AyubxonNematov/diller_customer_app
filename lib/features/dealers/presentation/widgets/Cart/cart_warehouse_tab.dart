import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sement_market_customer/core/theme/app_theme.dart';
import 'package:sement_market_customer/features/dealers/presentation/bloc/cart_bloc.dart';
import 'package:sement_market_customer/features/dealers/data/models/cart_item_model.dart';
import 'package:sement_market_customer/features/dealers/presentation/widgets/Cart/cart_item_card.dart';

class CartWarehouseTab extends StatelessWidget {
  const CartWarehouseTab({
    super.key,
    required this.items,
  });

  final List<CartItemModel> items;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildFreeDeliveryProgress(items),
        const SizedBox(height: 16),
        ...items.map((item) => CartItemCard(item: item)),
        const SizedBox(height: 16),
        _buildAddressSection(),
        const SizedBox(height: 100), // Spacing for sticky bottom
      ],
    );
  }

  Widget _buildFreeDeliveryProgress(List<CartItemModel> items) {
    const double threshold = 3000000;
    final currentTotal = items.fold(0.0, (sum, i) => sum + i.totalPrice);
    final progress = (currentTotal / threshold).clamp(0.0, 1.0);
    final remaining = threshold - currentTotal;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.local_shipping, size: 16, color: AppColors.darkNavy),
              SizedBox(width: 8),
              Text(
                'BEPUL YETKAZISH UCHUN',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.darkNavy),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.background,
            color: Colors.blue,
            borderRadius: BorderRadius.circular(4),
            minHeight: 6,
          ),
          const SizedBox(height: 12),
          Text(
            remaining > 0 
                ? 'Savat summasi ${_formatPrice(threshold.toStringAsFixed(0))} sumdan oshsa bepul.' 
                : 'Sizga bepul yetkazib beriladi!',
            style: const TextStyle(fontSize: 12, color: AppColors.grayText),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'YETKAZISH MANZILI',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.darkNavy),
          ),
          const SizedBox(height: 8),
          const Text(
            'adasdfa s asd',
            style: TextStyle(fontSize: 14, color: AppColors.darkNavy),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('TAHRIRLASH', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  String _formatPrice(String price) {
    try {
      final value = double.tryParse(price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
      return value.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
    } catch (_) {
      return price;
    }
  }
}
