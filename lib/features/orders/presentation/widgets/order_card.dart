import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sement_market_customer/core/theme/app_theme.dart';
import 'package:sement_market_customer/features/orders/data/models/order_model.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  final OrderModel order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.darkNavy.withValues(alpha: 0.03),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.receipt_long,
                        color: AppColors.darkNavy, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Buyurtma #${order.id}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkNavy,
                          ),
                        ),
                        if (order.createdAt != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('dd.MM.yyyy, HH:mm')
                                .format(order.createdAt!.toLocal()),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.grayText,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  _buildStatusBadge(),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Warehouse
                  if (order.warehouse != null)
                    _buildInfoRow(
                      Icons.warehouse_outlined,
                      order.warehouse!.name,
                    ),

                  const SizedBox(height: 10),

                  // Delivery type
                  _buildInfoRow(
                    order.deliveryType == DeliveryType.pickup
                        ? Icons.store_outlined
                        : Icons.local_shipping_outlined,
                    order.deliveryType.label,
                  ),

                  const Divider(height: 20, thickness: 0.5),

                  // Price row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Jami:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grayText,
                        ),
                      ),
                      Text(
                        '${_formatPrice(order.totalPrice ?? '0')} so\'m',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.darkNavy,
                        ),
                      ),
                    ],
                  ),

                  if (order.totalEarnings != null &&
                      order.totalEarnings != '0.00') ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ish haqi:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.grayText,
                          ),
                        ),
                        Text(
                          '${_formatPrice(order.totalEarnings!)} so\'m',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Footer arrow
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Batafsil ko\'rish',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkNavy.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: AppColors.darkNavy.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (order.status) {
      case OrderStatus.new_:
        bgColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF1565C0);
        icon = Icons.fiber_new_rounded;
        break;
      case OrderStatus.inProcess:
        bgColor = const Color(0xFFFFF8E1);
        textColor = const Color(0xFFF57F17);
        icon = Icons.autorenew_rounded;
        break;
      case OrderStatus.completed:
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        icon = Icons.check_circle_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            order.status.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.grayText),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.darkNavy,
            ),
          ),
        ),
      ],
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
