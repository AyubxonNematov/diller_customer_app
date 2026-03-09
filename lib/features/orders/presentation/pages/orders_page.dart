import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sement_market_customer/core/theme/app_theme.dart';
import 'package:sement_market_customer/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:sement_market_customer/features/orders/presentation/widgets/order_card.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.receipt_long,
                        color: AppColors.darkNavy, size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'Buyurtmalarim',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.darkNavy,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: BlocBuilder<OrdersBloc, OrdersState>(
                builder: (context, state) {
                  if (state is OrdersLoading) {
                    return _buildShimmerLoading();
                  }

                  if (state is OrdersError) {
                    return _buildErrorState(context, state.message);
                  }

                  if (state is OrdersLoaded) {
                    if (state.orders.isEmpty) {
                      return _buildEmptyState();
                    }
                    return _buildOrdersList(context, state);
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context, OrdersLoaded state) {
    return RefreshIndicator(
      color: AppColors.darkNavy,
      onRefresh: () => context.read<OrdersBloc>().refresh(),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification &&
              notification.metrics.extentAfter < 200) {
            context.read<OrdersBloc>().add(const OrdersLoadMore());
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: state.orders.length + (state.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= state.orders.length) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.darkNavy,
                    strokeWidth: 2,
                  ),
                ),
              );
            }

            final order = state.orders[index];
            return OrderCard(
              order: order,
              onTap: () => context.push(
                '/zakazlar/${order.id}',
                extra: order,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.darkNavy.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Buyurtmalar yo\'q',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.darkNavy.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Siz hali hech qanday buyurtma bermadingiz',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.grayText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red[50],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
          ),
          const SizedBox(height: 16),
          Text(
            'Xatolik yuz berdi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.darkNavy,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.grayText),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => context.read<OrdersBloc>().add(const OrdersLoad()),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Qayta urinish'),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 5,
      itemBuilder: (_, __) => Container(
        height: 180,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.darkNavy,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}
