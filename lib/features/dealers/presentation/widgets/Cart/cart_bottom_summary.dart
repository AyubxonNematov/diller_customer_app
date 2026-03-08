import 'package:flutter/material.dart';
import 'package:sement_market_customer/core/theme/app_theme.dart';

class CartBottomSummary extends StatelessWidget {
  const CartBottomSummary({
    super.key,
    required this.totalAmount,
    required this.totalEarnings,
    required this.isDelivery,
    required this.onDeliveryTypeChanged,
    this.onBiddingTap,
  });

  final double totalAmount;
  final double totalEarnings;
  final bool isDelivery;
  final ValueChanged<bool> onDeliveryTypeChanged;
  final VoidCallback? onBiddingTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDeliveryTypeToggle(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mollar: ${_formatPrice(totalAmount.toStringAsFixed(0))} sum',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grayText),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isDelivery
                          ? 'Logistika: Hisoblanmagan'
                          : 'Logistika: O\'zim olaman',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDelivery
                              ? Colors.blue[700]
                              : AppColors.grayText),
                    ),
                  ],
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: _formatPrice(totalAmount.toStringAsFixed(0)),
                        style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: AppColors.darkNavy),
                      ),
                      const TextSpan(
                        text: ' SUM',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: AppColors.darkNavy),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (totalEarnings > 0)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wallet_giftcard,
                        size: 16, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 8),
                    Text(
                      'Jami ish haqi: +${_formatPrice(totalEarnings.toStringAsFixed(0))} sum',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2E7D32)),
                    ),
                  ],
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: FilledButton(
                onPressed: () {
                  if (isDelivery) {
                    onBiddingTap?.call();
                  } else {
                    // Place order logic
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFF5BF1A),
                  foregroundColor: AppColors.darkNavy,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  isDelivery ? 'HAYDOVCHI QIDIRISH' : 'BUYURTMA BERISH',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryTypeToggle() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Expanded(
            child: _toggleItem(
                '🚚 YETKAZISH', isDelivery, () => onDeliveryTypeChanged(true)),
          ),
          Expanded(
            child: _toggleItem('🏢 O\'ZIM OLAMAN', !isDelivery,
                () => onDeliveryTypeChanged(false)),
          ),
        ],
      ),
    );
  }

  Widget _toggleItem(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(21),
          boxShadow: isActive
              ? [const BoxShadow(color: Colors.black12, blurRadius: 4)]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: isActive ? AppColors.darkNavy : AppColors.grayText,
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
