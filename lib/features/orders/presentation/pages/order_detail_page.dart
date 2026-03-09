import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sement_market_customer/core/theme/app_theme.dart';
import 'package:sement_market_customer/features/orders/data/models/order_item_model.dart';
import 'package:sement_market_customer/features/orders/data/models/order_model.dart';

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({super.key, required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            expandedHeight: 100,
            pinned: true,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back_ios_new,
                    size: 18, color: AppColors.darkNavy),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.only(left: 56, bottom: 16, right: 16),
              title: Text(
                'Buyurtma #${order.id}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkNavy,
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Status & date card
                _buildHeaderCard(),
                const SizedBox(height: 16),

                // Warehouse info
                if (order.warehouse != null) ...[
                  _buildWarehouseCard(),
                  const SizedBox(height: 16),
                ],

                // Items
                _buildSectionTitle('Mahsulotlar', Icons.inventory_2_outlined),
                const SizedBox(height: 8),
                ...order.items.map(_buildItemCard),
                const SizedBox(height: 16),

                // Totals
                _buildTotalsCard(),
                const SizedBox(height: 16),

                // Logistic info
                if (order.logistic != null) ...[
                  _buildLogisticCard(),
                  const SizedBox(height: 16),
                ],

                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    Color statusBg;
    Color statusText;
    IconData statusIcon;

    switch (order.status) {
      case OrderStatus.new_:
        statusBg = const Color(0xFFE3F2FD);
        statusText = const Color(0xFF1565C0);
        statusIcon = Icons.fiber_new_rounded;
        break;
      case OrderStatus.inProcess:
        statusBg = const Color(0xFFFFF8E1);
        statusText = const Color(0xFFF57F17);
        statusIcon = Icons.autorenew_rounded;
        break;
      case OrderStatus.completed:
        statusBg = const Color(0xFFE8F5E9);
        statusText = const Color(0xFF2E7D32);
        statusIcon = Icons.check_circle_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(statusIcon, color: statusText, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Holat',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grayText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.status.label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: statusText,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      order.deliveryType == DeliveryType.pickup
                          ? Icons.store_outlined
                          : Icons.local_shipping_outlined,
                      size: 14,
                      color: AppColors.darkNavy,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      order.deliveryType.label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkNavy,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (order.createdAt != null) ...[
            const Divider(height: 20, thickness: 0.5),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 16, color: AppColors.grayText),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd MMMM yyyy, HH:mm')
                      .format(order.createdAt!.toLocal()),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkNavy,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWarehouseCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.warehouse_outlined,
                color: Color(0xFF2E7D32), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.warehouse!.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkNavy,
                  ),
                ),
                if (order.warehouse!.address.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    order.warehouse!.address,
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
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.darkNavy),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.darkNavy,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '${order.items.length}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.darkNavy,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(OrderItemModel orderItem) {
    final product = orderItem.product;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product image
          if (product != null && product.firstImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                product.firstImage!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
              ),
            )
          else
            _buildPlaceholderImage(),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product?.name ?? 'Mahsulot #${orderItem.productId}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkNavy,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${orderItem.quantity} ${orderItem.unitName ?? 'dona'} × ${_formatPrice(orderItem.price)} so\'m',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.grayText,
                  ),
                ),
              ],
            ),
          ),

          // Total price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_formatPrice(orderItem.totalPrice.toStringAsFixed(0))} so\'m',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkNavy,
                ),
              ),
              if (orderItem.earnings != null) ...[
                const SizedBox(height: 2),
                Text(
                  '+${_formatPrice(orderItem.totalEarnings.toStringAsFixed(0))}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.image_outlined, color: AppColors.grayText),
    );
  }

  Widget _buildTotalsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.darkNavy,
            AppColors.darkNavy.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkNavy.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTotalRow(
            'Jami narx:',
            '${_formatPrice(order.totalPrice ?? '0')} so\'m',
            Colors.white,
            fontSize: 18,
          ),
          if (order.totalEarnings != null && order.totalEarnings != '0.00') ...[
            const SizedBox(height: 10),
            Divider(
              color: Colors.white.withValues(alpha: 0.15),
              thickness: 0.5,
            ),
            const SizedBox(height: 10),
            _buildTotalRow(
              'Ish haqi:',
              '${_formatPrice(order.totalEarnings!)} so\'m',
              AppColors.gold,
              fontSize: 15,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, Color valueColor,
      {double fontSize = 14}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildLogisticCard() {
    final logistic = order.logistic!;
    final status = logistic['status']?.toString() ?? 'new';

    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_shipping_outlined,
                    color: Color(0xFF1565C0), size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'Logistika',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkNavy,
                ),
              ),
            ],
          ),
          const Divider(height: 20, thickness: 0.5),
          _buildLogisticRow('Holat', _logisticStatusLabel(status)),
          if (logistic['price'] != null)
            _buildLogisticRow(
                'Narx', '${_formatPrice(logistic['price'].toString())} so\'m'),
        ],
      ),
    );
  }

  Widget _buildLogisticRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.grayText,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.darkNavy,
            ),
          ),
        ],
      ),
    );
  }

  String _logisticStatusLabel(String status) {
    switch (status) {
      case 'new':
        return 'Yangi';
      case 'en_route_to_pickup':
        return 'Olib ketish yo\'lida';
      case 'pickup_in_progress':
        return 'Yuklash jarayonida';
      case 'out_for_delivery':
        return 'Yetkazilmoqda';
      case 'delivered':
        return 'Yetkazildi';
      case 'cash_pending':
        return 'To\'lov kutilmoqda';
      case 'cash_settled':
        return 'To\'lov qilindi';
      case 'completed':
        return 'Yakunlangan';
      default:
        return status;
    }
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
