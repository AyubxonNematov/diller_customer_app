import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sement_market_customer/core/theme/app_theme.dart';
import 'package:sement_market_customer/l10n/app_localizations.dart';
import 'package:sement_market_customer/features/dealers/data/models/dealer_model.dart';
import 'package:sement_market_customer/features/dealers/presentation/bloc/warehouses_bloc.dart';
import 'package:sement_market_customer/features/dealers/presentation/widgets/dealers_empty_state.dart';
import 'package:sement_market_customer/features/dealers/presentation/widgets/dealers_error_state.dart';
import 'package:sement_market_customer/features/dealers/presentation/widgets/warehouse_card.dart';
import 'package:sement_market_customer/features/dealers/presentation/widgets/warehouses_search_bar.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WarehousesBloc>().add(const WarehousesLoad());
    });
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
          _DealerHeader(
            dealer: widget.dealer,
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
                            return WarehouseCard(
                              key: ValueKey(state.warehouses[index].id),
                              warehouse: state.warehouses[index],
                            );
                          },
                        ),
                      ),
                      if (state.isRefreshing)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Material(
                            elevation: 0,
                            color: Colors.white.withValues(alpha: 0.8),
                            child: SafeArea(
                              bottom: false,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.darkNavy,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      AppLocalizations.of(context)!
                                          .dealersLoading,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.grayText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
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

class _DealerHeader extends StatelessWidget {
  const _DealerHeader({
    required this.dealer,
    required this.onBack,
  });

  final DealerModel dealer;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.darkNavy,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 4,
        right: 16,
        bottom: 14,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 22,
              ),
              onPressed: onBack,
              style: IconButton.styleFrom(
                minimumSize: const Size(48, 48),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dealer.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (dealer.address != null &&
                      dealer.address!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      dealer.address!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
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
