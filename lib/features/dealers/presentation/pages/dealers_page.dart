import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sement_market_customer/core/theme/app_theme.dart';
import 'package:sement_market_customer/l10n/app_localizations.dart';
import 'package:sement_market_customer/features/dealers/presentation/bloc/dealers_bloc.dart';
import 'package:sement_market_customer/features/dealers/presentation/widgets/Dealers/dealer_card.dart';
import 'package:sement_market_customer/features/dealers/presentation/widgets/Dealers/dealer_card_skeleton.dart';
import 'package:sement_market_customer/features/dealers/presentation/widgets/Dealers/dealer_search_bar.dart';
import 'package:sement_market_customer/features/dealers/presentation/widgets/Dealers/dealers_empty_state.dart';
import 'package:sement_market_customer/features/dealers/presentation/widgets/Dealers/dealers_error_state.dart';
import 'package:sement_market_customer/features/dealers/presentation/widgets/Dealers/dealers_filter_modal.dart';
import 'package:sement_market_customer/core/utils/location_helper.dart';
import 'package:sement_market_customer/core/utils/location_helper.dart';

class DealersPage extends StatefulWidget {
  const DealersPage({super.key});

  @override
  State<DealersPage> createState() => _DealersPageState();
}

class _DealersPageState extends State<DealersPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLocation();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _checkLocation() async {
    if (!mounted) return;
    final status = await LocationHelper.checkPermission();
    if (!mounted) return;
    if (status == LocationPermission.denied ||
        status == LocationPermission.unableToDetermine) {
      _showLocationDialog(deniedForever: false);
    } else if (status == LocationPermission.deniedForever) {
      _showLocationDialog(deniedForever: true);
    }
  }

  void _showLocationDialog({required bool deniedForever}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFF4C400).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on,
                color: Color(0xFFF4C400),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(ctx)!.locationPermission,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0E1A33),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(ctx)!.locationDesc,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF9EA6B3),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0E1A33),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  if (deniedForever) {
                    await Geolocator.openAppSettings();
                  } else {
                    await Geolocator.requestPermission();
                  }
                },
                child: Text(
                  deniedForever
                      ? AppLocalizations.of(ctx)!.openSettings
                      : AppLocalizations.of(ctx)!.grantPermission,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                AppLocalizations.of(ctx)!.later,
                style: const TextStyle(color: Color(0xFF9EA6B3)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    await context.read<DealersBloc>().refresh();
  }

  void _onFilterTap() {
    final bloc = context.read<DealersBloc>();
    final state = bloc.state;
    if (state is! DealersLoaded) return;

    DealersFilterModal.show(
      context,
      currentCategoryId: state.selectedCategoryId,
      currentRegionId: state.selectedRegionId,
      onApply: ({categoryId, regionId}) {
        bloc.add(DealersFiltersApplied(
          categoryId: categoryId,
          regionId: regionId,
        ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          BlocBuilder<DealersBloc, DealersState>(
            buildWhen: (p, c) =>
                p is DealersLoaded != c is DealersLoaded ||
                (c is DealersLoaded &&
                    p is DealersLoaded &&
                    (p.searchQuery != c.searchQuery ||
                        p.activeFiltersCount != c.activeFiltersCount)),
            builder: (context, state) {
              return DealerSearchBar(
                searchQuery: state is DealersLoaded ? state.searchQuery : null,
                activeFiltersCount:
                    state is DealersLoaded ? state.activeFiltersCount : 0,
                onChanged: (q) => context.read<DealersBloc>().add(
                      DealersSearchChanged(q),
                    ),
                onFilterTap: _onFilterTap,
              );
            },
          ),
          Expanded(
            child: BlocBuilder<DealersBloc, DealersState>(
              builder: (context, state) {
                if (state is DealersLoading) {
                  return _buildSkeletonLoading();
                }
                if (state is DealersError) {
                  return DealersErrorState(
                    message: state.message,
                    onRetry: () =>
                        context.read<DealersBloc>().add(const DealersLoad()),
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
                      itemCount:
                          state.dealers.length + (state.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= state.dealers.length) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            context
                                .read<DealersBloc>()
                                .add(const DealersLoadMore());
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoading() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: 6,
      itemBuilder: (_, __) => const DealerCardSkeleton(),
    );
  }
}
