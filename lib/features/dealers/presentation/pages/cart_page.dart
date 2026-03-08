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
      return;
    }

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
        // Empty cart
        if (state.entries.isEmpty) {
          _updateTabController(0);
          return const CartEmptyState();
        }

        // Loading state (no warehouse data yet)
        if (state.isLoading && !state.hasData) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: const Text('Savat',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.darkNavy)),
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // Error state
        if (state.error != null && !state.hasData) {
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
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Xatolik yuz berdi',
                      style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<CartBloc>().add(LoadCartData()),
                    child: const Text('Qayta urinish'),
                  ),
                ],
              ),
            ),
          );
        }

        final warehouseIds = state.warehouseIds;
        if (warehouseIds.isEmpty) {
          _updateTabController(0);
          return const CartEmptyState();
        }

        _updateTabController(warehouseIds.length);

        if (_tabController == null) {
          return const SizedBox.shrink();
        }

        // Get data for the currently active tab
        final safeIndex = _currentTabIndex.clamp(0, warehouseIds.length - 1);
        final activeWarehouseId = warehouseIds[safeIndex];
        final activeData = state.warehouseData[activeWarehouseId]!;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: CartAppBar(
            tabController: _tabController,
            warehouseIds: warehouseIds,
            warehouseData: state.warehouseData,
          ),
          body: Column(
            children: [
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: warehouseIds.map((id) {
                    final data = state.warehouseData[id]!;
                    return CartWarehouseTab(
                      items: data.items,
                      freeDeliveryThreshold: data.freeDeliveryThreshold,
                    );
                  }).toList(),
                ),
              ),
              CartBottomSummary(
                totalAmount: activeData.totalPrice,
                totalEarnings: activeData.totalEarnings,
                isDelivery: _isDelivery,
                onDeliveryTypeChanged: (val) =>
                    setState(() => _isDelivery = val),
                onBiddingTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LogisticsBiddingPage(
                        warehouseName: activeData.warehouse.name,
                        offeredPrice: activeData.totalPrice,
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
