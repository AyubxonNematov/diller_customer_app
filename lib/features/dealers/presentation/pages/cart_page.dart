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

class _CartPageState extends State<CartPage> with TickerProviderStateMixin {
  TabController? _tabController;
  bool _isDelivery = true;
  int _currentTabIndex = 0;
  int _previousTabCount = 0;

  @override
  void dispose() {
    _tabController?.removeListener(_onTabChanged);
    _tabController?.dispose();
    _tabController = null;
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController != null && !_tabController!.indexIsChanging) {
      setState(() {
        _currentTabIndex = _tabController!.index;
      });
    }
  }

  void _updateTabController(int newLength) {
    if (newLength == 0) {
      // Defer disposal to after the current frame to avoid ticker assertion
      if (_tabController != null) {
        final oldController = _tabController!;
        _tabController = null;
        _previousTabCount = 0;
        _currentTabIndex = 0;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          oldController.removeListener(_onTabChanged);
          oldController.dispose();
        });
      }
      return;
    }

    if (_previousTabCount == newLength && _tabController != null) {
      return; // No change needed
    }

    // Defer old controller disposal and create new one after frame
    final oldController = _tabController;
    final safeIndex = _currentTabIndex.clamp(0, newLength - 1);

    _tabController = TabController(
      length: newLength,
      vsync: this,
      initialIndex: safeIndex,
    );
    _tabController!.addListener(_onTabChanged);
    _currentTabIndex = safeIndex;
    _previousTabCount = newLength;

    if (oldController != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        oldController.removeListener(_onTabChanged);
        oldController.dispose();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        if (state.items.isEmpty) {
          _updateTabController(0);
          return const CartEmptyState();
        }

        final grouped = state.groupedItems;
        final warehouseIds = grouped.keys.toList();

        _updateTabController(warehouseIds.length);

        if (_tabController == null) {
          return const SizedBox.shrink();
        }

        // Get items for the currently active tab
        final safeIndex = _currentTabIndex.clamp(0, warehouseIds.length - 1);
        final activeWarehouseId = warehouseIds[safeIndex];
        final activeTabItems = grouped[activeWarehouseId]!;
        final activeTabTotal =
            activeTabItems.fold(0.0, (sum, item) => sum + item.totalPrice);
        final activeTabEarnings =
            activeTabItems.fold(0.0, (sum, item) => sum + item.totalEarnings);
        final activeWarehouseName =
            activeTabItems.first.warehouseName ?? 'Ombor';

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
                  children: warehouseIds
                      .map((id) => CartWarehouseTab(items: grouped[id]!))
                      .toList(),
                ),
              ),
              CartBottomSummary(
                totalAmount: activeTabTotal,
                totalEarnings: activeTabEarnings,
                isDelivery: _isDelivery,
                onDeliveryTypeChanged: (val) =>
                    setState(() => _isDelivery = val),
                onBiddingTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LogisticsBiddingPage(
                        warehouseName: activeWarehouseName,
                        offeredPrice: activeTabTotal,
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
