import 'package:flutter/material.dart';
import 'package:sement_market_customer/core/theme/app_theme.dart';
import 'package:sement_market_customer/features/dealers/data/models/product_model.dart';

class ProductDetailsModal extends StatelessWidget {
  const ProductDetailsModal({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  final ProductModel product;
  final VoidCallback onAddToCart;

  static void show(
    BuildContext context, {
    required ProductModel product,
    required VoidCallback onAddToCart,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductDetailsModal(
        product: product,
        onAddToCart: onAddToCart,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // Product Image
                AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: product.firstImage != null
                          ? Image.network(
                              product.firstImage!,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.image_outlined,
                              size: 64, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Brand
                Text(
                  product.brandName?.toUpperCase() ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                // Name
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkNavy,
                  ),
                ),
                const SizedBox(height: 16),
                // Price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatPrice(product.price),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.darkNavy,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        'SUM / ${product.unitName ?? 'qop'}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.grayText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),
                // Description Section
                const Text(
                  'MAHSULOT HAQIDA',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkNavy,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  product.description ??
                      'Mahsulot haqida batafsil ma\'lumot tez kunda qo\'shiladi.',
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.darkNavy,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          // Bottom Action
          Padding(
            padding: EdgeInsets.fromLTRB(
              24, 
              16, 
              24, 
              16 + MediaQuery.of(context).padding.bottom
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  onAddToCart();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.darkNavy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'SAVATGA QO\'SHISH',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(String price) {
    try {
      final val = double.tryParse(price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
      final buffer = StringBuffer();
      final str = val.toInt().toString();
      for (int i = 0; i < str.length; i++) {
        if ((str.length - i) % 3 == 0 && i != 0) buffer.write(',');
        buffer.write(str[i]);
      }
      return buffer.toString();
    } catch (_) {
      return price;
    }
  }
}
