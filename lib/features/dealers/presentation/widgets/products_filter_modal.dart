import 'package:flutter/material.dart';
import 'package:sement_market_customer/core/di/injection.dart';
import 'package:sement_market_customer/core/theme/app_theme.dart';
import 'package:sement_market_customer/core/api/catalog_api.dart';
import 'package:sement_market_customer/features/dealers/data/models/brand_model.dart';
import 'package:sement_market_customer/features/dealers/data/models/warehouse_model.dart';
import 'package:sement_market_customer/l10n/app_localizations.dart';

class ProductsFilterModal extends StatefulWidget {
  const ProductsFilterModal({
    super.key,
    required this.warehouse,
    required this.currentBrandId,
    required this.onApply,
  });

  final WarehouseModel warehouse;
  final int? currentBrandId;
  final void Function({int? brandId}) onApply;

  static Future<void> show(
    BuildContext context, {
    required WarehouseModel warehouse,
    required int? currentBrandId,
    required void Function({int? brandId}) onApply,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ProductsFilterModal(
        warehouse: warehouse,
        currentBrandId: currentBrandId,
        onApply: onApply,
      ),
    );
  }

  @override
  State<ProductsFilterModal> createState() => _ProductsFilterModalState();
}

class _ProductsFilterModalState extends State<ProductsFilterModal> {
  final CatalogApi _api = getIt<CatalogApi>();

  List<BrandModel> _brands = [];
  bool _loading = true;
  int? _selectedBrandId;

  @override
  void initState() {
    super.initState();
    _selectedBrandId = widget.currentBrandId;
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final brands = await _api.getWarehouseBrands(widget.warehouse.id);
      if (mounted) {
        setState(() {
          _brands = brands;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onApply() {
    widget.onApply(brandId: _selectedBrandId);
    Navigator.of(context).pop();
  }

  void _onClear() {
    setState(() => _selectedBrandId = null);
    widget.onApply(brandId: null);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.25,
      maxChildSize: 0.85,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: AppColors.graySubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.filter,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkNavy,
                      ),
                    ),
                    if (_selectedBrandId != null)
                      TextButton(
                        onPressed: _onClear,
                        child: Text(
                          AppLocalizations.of(context)!.filterClear,
                          style: const TextStyle(
                            color: AppColors.grayText,
                            fontSize: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.darkNavy,
                          strokeWidth: 2,
                        ),
                      )
                    : ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        children: [
                          Text(
                            AppLocalizations.of(context)!.filterBrand,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.grayText,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (_brands.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Text(
                                  AppLocalizations.of(context)!.productsEmpty,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.grayText,
                                  ),
                                ),
                              ),
                            )
                          else
                            ..._brands.map((brand) {
                              final isSelected = _selectedBrandId == brand.id;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedBrandId =
                                            isSelected ? null : brand.id;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.goldLight
                                            : AppColors.background,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              brand.name,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: isSelected
                                                    ? FontWeight.w700
                                                    : FontWeight.w500,
                                                color: isSelected
                                                    ? AppColors.darkNavy
                                                    : AppColors.darkNavy,
                                              ),
                                            ),
                                          ),
                                          if (isSelected)
                                            Icon(
                                              Icons.check_rounded,
                                              size: 22,
                                              color: AppColors.darkNavy,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                        ],
                      ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _onApply,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.darkNavy,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.filterApply,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
