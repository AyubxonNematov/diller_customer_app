import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sement_market_customer/core/theme/app_theme.dart';
import 'package:sement_market_customer/features/dealers/presentation/bloc/cart_bloc.dart';
import 'package:sement_market_customer/features/dealers/data/models/cart_item_model.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _isDelivery = true;

  @override
  void dispose() {
    _tabController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        if (state.items.isEmpty) {
          return _buildEmptyState();
        }

        final grouped = state.groupedItems;
        final warehouseIds = grouped.keys.toList();

        if (_tabController == null || _tabController!.length != warehouseIds.length) {
          _tabController?.dispose();
          _tabController = TabController(length: warehouseIds.length, vsync: this);
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(warehouseIds, grouped),
          body: Column(
            children: [
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: warehouseIds.map((id) => _buildWarehouseTab(grouped[id]!)).toList(),
                ),
              ),
              _buildBottomSummary(state),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(List<int> warehouseIds, Map<int, List<CartItemModel>> grouped) {
    return AppBar(
      backgroundColor: Colors.white,
      title: const Text(
        'Savat',
        style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.darkNavy),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Align(
          alignment: Alignment.centerLeft,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: Colors.transparent,
            dividerColor: Colors.transparent,
            tabAlignment: TabAlignment.start,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            labelPadding: const EdgeInsets.only(right: 8),
            tabs: warehouseIds.map((id) {
              final group = grouped[id]!;
              final name = group.first.warehouseName ?? 'Ombor';
              return Tab(
                height: 36,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.darkNavy,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.check, size: 12, color: Colors.green),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.gold,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          group.length.toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: AppColors.darkNavy,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Savat'),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_cart_outlined, size: 80, color: AppColors.graySubtle),
            const SizedBox(height: 16),
            const Text(
              'Savat bo\'sh',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/diller'),
              child: const Text('Xaridni boshlash'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarehouseTab(List<CartItemModel> items) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildFreeDeliveryProgress(items),
        const SizedBox(height: 16),
        ...items.map((item) => _buildCartItemCard(item)),
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

  Widget _buildCartItemCard(CartItemModel item) {
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
                  errorBuilder: (_, __, ___) => Container(color: AppColors.background, child: const Icon(Icons.image)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.darkNavy),
                    ),
                    Text(
                      '${_formatPrice(item.product.price)} sum / ${item.product.unitName ?? 'qop'}',
                      style: const TextStyle(fontSize: 12, color: AppColors.darkNavy, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => context.read<CartBloc>().add(RemoveFromCart(item.product.id)),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                style: IconButton.styleFrom(backgroundColor: Colors.red.shade50),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 0.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildQuantityController(item),
              Text(
                '${_formatPrice(item.totalPrice.toStringAsFixed(0))} sum',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.darkNavy),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _quickAdjustButton(item, -500),
              const SizedBox(width: 8),
              _quickAdjustButton(item, -50),
              const SizedBox(width: 8),
              _quickAdjustButton(item, 50),
              const SizedBox(width: 8),
              _quickAdjustButton(item, 500),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityController(CartItemModel item) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.background, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => context.read<CartBloc>().add(UpdateCartItemQuantity(productId: item.product.id, quantity: item.quantity - 1)),
            icon: const Icon(Icons.remove, size: 16),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              item.quantity.toString(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
          ),
          IconButton(
            onPressed: () => context.read<CartBloc>().add(UpdateCartItemQuantity(productId: item.product.id, quantity: item.quantity + 1)),
            icon: const Icon(Icons.add, size: 16),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  Widget _quickAdjustButton(CartItemModel item, int delta) {
    return Expanded(
      child: InkWell(
        onTap: () => context.read<CartBloc>().add(UpdateCartItemQuantity(productId: item.product.id, quantity: item.quantity + delta)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.background, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            (delta > 0 ? '+$delta' : '$delta'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: delta > 0 ? Colors.green.shade700 : Colors.red.shade400,
            ),
          ),
        ),
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

  Widget _buildBottomSummary(CartState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
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
                      'Mollar: ${_formatPrice(state.totalAmount.toStringAsFixed(0))} sum',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.grayText),
                    ),
                    Text(
                      _isDelivery ? 'Logistika: +95,000 sum' : 'Logistika: Hisoblanmagan',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _isDelivery ? Colors.blue : AppColors.grayText),
                    ),
                    if (state.totalEarnings > 0)
                      Text(
                        'Bonus: +${_formatPrice(state.totalEarnings.toStringAsFixed(0))} sum',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2E7D32)),
                      ),
                  ],
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: _formatPrice((state.totalAmount + (_isDelivery ? 95000 : 0)).toStringAsFixed(0)),
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.darkNavy),
                      ),
                      const TextSpan(
                        text: ' SUM',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.darkNavy),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: _isDelivery ? AppColors.gold : Colors.blue,
                foregroundColor: _isDelivery ? AppColors.darkNavy : Colors.white,
              ),
              child: Text(_isDelivery ? 'BUYURTMA BERISH' : 'HAYDOVCHI QIDIRISH'),
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
            child: _toggleItem('🚚 YETKAZISH', _isDelivery, () => setState(() => _isDelivery = true)),
          ),
          Expanded(
            child: _toggleItem('🏢 O\'ZIM OLAMAN', !_isDelivery, () => setState(() => _isDelivery = false)),
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
          boxShadow: isActive ? [const BoxShadow(color: Colors.black12, blurRadius: 4)] : null,
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
