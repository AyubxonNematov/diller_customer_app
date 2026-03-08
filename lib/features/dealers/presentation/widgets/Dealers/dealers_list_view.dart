import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sement_market_customer/core/theme/app_theme.dart';
import 'package:sement_market_customer/features/dealers/presentation/bloc/dealers_bloc.dart';
import 'package:sement_market_customer/features/dealers/presentation/widgets/Dealers/dealer_card.dart';
import 'package:sement_market_customer/features/dealers/presentation/widgets/Dealers/dealer_card_skeleton.dart';
import 'package:sement_market_customer/features/dealers/presentation/widgets/Dealers/dealers_empty_state.dart';
import 'package:sement_market_customer/features/dealers/presentation/widgets/Dealers/dealers_error_state.dart';

class DealersListView extends StatefulWidget {
  const DealersListView({super.key});

  @override
  State<DealersListView> createState() => _DealersListViewState();
}

class _DealersListViewState extends State<DealersListView> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await context.read<DealersBloc>().refresh();
  }

  Widget _buildSkeletonLoading() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: 6,
      itemBuilder: (_, __) => const DealerCardSkeleton(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DealersBloc, DealersState>(
      builder: (context, state) {
        if (state is DealersLoading) {
          return _buildSkeletonLoading();
        }
        if (state is DealersError) {
          return DealersErrorState(
            message: state.message,
            onRetry: () => context.read<DealersBloc>().add(const DealersLoad()),
          );
        }
        if (state is DealersLoaded) {
          if (state.isRefreshing) {
            return _buildSkeletonLoading();
          }
          if (state.dealers.isEmpty) {
            return DealersEmptyState(
              hasActiveFilters: state.activeFiltersCount > 0,
              onRetry: () =>
                  context.read<DealersBloc>().add(const DealersLoad()),
              onClearFilters: () => context.read<DealersBloc>().add(
                    const DealersFiltersApplied(
                      categoryId: null,
                      regionId: null,
                    ),
                  ),
            );
          }
          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppColors.darkNavy,
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: 16 +
                    (state.hasMore ? 60 : 0) +
                    MediaQuery.of(context).padding.bottom,
              ),
              itemCount: state.dealers.length + (state.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= state.dealers.length) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.read<DealersBloc>().add(const DealersLoadMore());
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
                final dealer = state.dealers[index];
                return DealerCard(
                  key: ValueKey(dealer.id),
                  dealer: dealer,
                  onTap: () {
                    context.push(
                      '/diller/${dealer.id}',
                      extra: dealer,
                    );
                  },
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
