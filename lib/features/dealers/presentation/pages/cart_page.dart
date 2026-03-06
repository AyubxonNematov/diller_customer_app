import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sement_market_customer/core/theme/app_theme.dart';
import 'package:sement_market_customer/features/dealers/presentation/bloc/cart_bloc.dart';
import 'package:sement_market_customer/features/dealers/presentation/widgets/Cart/cart_app_bar.dart';
import 'package:sement_market_customer/features/dealers/presentation/widgets/Cart/cart_empty_state.dart';
import 'package:sement_market_customer/features/dealers/presentation/widgets/Cart/cart_warehouse_tab.dart';
import 'package:sement_market_customer/features/dealers/presentation/widgets/Cart/cart_bottom_summary.dart';
import 'package:sement_market_customer/features/dealers/presentation/pages/logistics_bidding_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  bool _isDelivery = true;

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        if (state.items.isEmpty) {
          return const CartEmptyState();
        }

        final grouped = state.groupedItems;
        final warehouseIds = grouped.keys.toList();

        if (_tabController == null || _tabController!.length != warehouseIds.length) {
          _tabController?.dispose();
          _tabController = TabController(length: warehouseIds.length, vsync: this);
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: CartAppBar(
            tabController: _tabController,
            warehouseIds: warehouseIds,
            grouped: grouped,
          ),
          body: Column(
            children: [
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: warehouseIds.map((id) => CartWarehouseTab(items: grouped[id]!)).toList(),
                ),
              ),
              CartBottomSummary(
                state: state,
                isDelivery: _isDelivery,
                onDeliveryTypeChanged: (val) => setState(() => _isDelivery = val),
                onBiddingTap: () {
                  final activeWarehouseId = warehouseIds[_tabController!.index];
                  final warehouseName = grouped[activeWarehouseId]!.first.warehouseName ?? 'Ombor';
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LogisticsBiddingPage(
                        warehouseName: warehouseName,
                        offeredPrice: state.totalAmount,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
