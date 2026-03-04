import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sement_market_customer/core/theme/app_theme.dart';
import 'package:sement_market_customer/l10n/app_localizations.dart';
import 'package:sement_market_customer/features/dealers/data/models/dealer_model.dart';
import 'package:sement_market_customer/features/dealers/presentation/bloc/warehouses_bloc.dart';
import 'package:sement_market_customer/features/dealers/presentation/widgets/dealers_empty_state.dart';
import 'package:sement_market_customer/features/dealers/presentation/widgets/dealers_error_state.dart';
import 'package:sement_market_customer/features/dealers/presentation/widgets/warehouse_card.dart';
import 'package:sement_market_customer/features/dealers/presentation/widgets/warehouses_search_bar.dart';
import 'package:sement_market_customer/core/widgets/detail_page_header.dart';
import 'package:sement_market_customer/core/widgets/refreshing_overlay.dart';

class DealerWarehousesPage extends StatefulWidget {
  const DealerWarehousesPage({
    super.key,
    required this.dealer,
  });

  final DealerModel dealer;

  @override
  State<DealerWarehousesPage> createState() => _DealerWarehousesPageState();
}

class _DealerWarehousesPageState extends State<DealerWarehousesPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await context.read<WarehousesBloc>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          DetailPageHeader(
            title: widget.dealer.name,
            subtitle: widget.dealer.address,
            onBack: () => Navigator.of(context).pop(),
          ),
          BlocBuilder<WarehousesBloc, WarehousesState>(
            buildWhen: (p, c) =>
                p is WarehousesLoaded != c is WarehousesLoaded ||
                (c is WarehousesLoaded &&
                    p is WarehousesLoaded &&
                    p.searchQuery != c.searchQuery),
            builder: (context, state) {
              if (state is WarehousesLoaded) {
                return WarehousesSearchBar(
                  searchQuery: state.searchQuery,
                  onChanged: (q) => context.read<WarehousesBloc>().add(
                        WarehousesSearchChanged(q),
                      ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          Expanded(
            child: BlocBuilder<WarehousesBloc, WarehousesState>(
              builder: (context, state) {
                if (state is WarehousesLoading) {
                  return _buildSkeleton();
                }
                if (state is WarehousesError) {
                  return DealersErrorState(
                    message: state.message,
                    onRetry: () => context
                        .read<WarehousesBloc>()
                        .add(const WarehousesLoad()),
                  );
                }
                if (state is WarehousesLoaded) {
                  if (state.warehouses.isEmpty && !state.isRefreshing) {
                    return DealersEmptyState(
                      emptyTitle:
                          AppLocalizations.of(context)!.warehousesEmpty,
                      emptyHint:
                          AppLocalizations.of(context)!.warehousesEmptyHint,
                      onRetry: () => context
                          .read<WarehousesBloc>()
                          .add(const WarehousesLoad()),
                    );
                  }
                  return Stack(
                    children: [
                      RefreshIndicator(
                        onRefresh: _onRefresh,
                        color: AppColors.darkNavy,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 8,
                            bottom: 16 +
                                (state.hasMore ? 60 : 0) +
                                MediaQuery.of(context).padding.bottom,
                          ),
                          itemCount:
                              state.warehouses.length + (state.hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= state.warehouses.length) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                context
                                    .read<WarehousesBloc>()
                                    .add(const WarehousesLoadMore());
                              });
                              return state.isLoadingMore
                                  ? const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.darkNavy,
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink();
                            }
                        final warehouse = state.warehouses[index];
                        return WarehouseCard(
                          key: ValueKey(warehouse.id),
                          warehouse: warehouse,
                          onTap: () => context.push(
                            '/diller/${widget.dealer.id}/w/${warehouse.id}',
                            extra: warehouse,
                          ),
                        );
                          },
                        ),
                      ),
                      RefreshingOverlay(
                        isRefreshing: state.isRefreshing,
                        message: AppLocalizations.of(context)!.dealersLoading,
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: 5,
      itemBuilder: (_, __) => _WarehouseCardSkeleton(),
    );
  }
}


class _WarehouseCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.graySubtle.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.graySubtle.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 120,
                        decoration: BoxDecoration(
                          color: AppColors.graySubtle.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
