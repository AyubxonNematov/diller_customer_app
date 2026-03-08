import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sement_market_customer/core/theme/app_theme.dart';
import 'package:sement_market_customer/features/dealers/presentation/bloc/dealers_bloc.dart';
import 'package:sement_market_customer/features/dealers/presentation/widgets/Dealers/dealer_search_bar.dart';
import 'package:sement_market_customer/features/dealers/presentation/widgets/Dealers/dealers_filter_modal.dart';
import 'package:sement_market_customer/features/dealers/presentation/widgets/Dealers/dealers_list_view.dart';
import 'package:sement_market_customer/features/dealers/presentation/widgets/Dealers/location_permission_dialog.dart';
import 'package:sement_market_customer/core/utils/location_helper.dart';

class DealersPage extends StatefulWidget {
  const DealersPage({super.key});

  @override
  State<DealersPage> createState() => _DealersPageState();
}

class _DealersPageState extends State<DealersPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLocation();
    });
  }

  Future<void> _checkLocation() async {
    if (!mounted) return;
    final status = await LocationHelper.checkPermission();
    if (!mounted) return;
    if (status == LocationPermission.denied ||
        status == LocationPermission.unableToDetermine) {
      LocationPermissionDialog.show(context, deniedForever: false);
    } else if (status == LocationPermission.deniedForever) {
      LocationPermissionDialog.show(context, deniedForever: true);
    }
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
          const Expanded(
            child: DealersListView(),
          ),
        ],
      ),
    );
  }
}
