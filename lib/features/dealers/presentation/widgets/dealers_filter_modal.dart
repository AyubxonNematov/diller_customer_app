import 'package:flutter/material.dart';
import 'package:sement_market_customer/core/di/injection.dart';
import 'package:sement_market_customer/core/theme/app_theme.dart';
import 'package:sement_market_customer/core/api/catalog_api.dart';
import 'package:sement_market_customer/features/dealers/data/models/category_model.dart';
import 'package:sement_market_customer/features/dealers/data/models/region_model.dart';
import 'package:sement_market_customer/l10n/app_localizations.dart';

class DealersFilterModal extends StatefulWidget {
  const DealersFilterModal({
    super.key,
    required this.currentCategoryId,
    required this.currentRegionId,
    required this.onApply,
  });

  final int? currentCategoryId;
  final int? currentRegionId;
  final void Function({int? categoryId, int? regionId}) onApply;

  static Future<void> show(
    BuildContext context, {
    required int? currentCategoryId,
    required int? currentRegionId,
    required void Function({int? categoryId, int? regionId}) onApply,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DealersFilterModal(
        currentCategoryId: currentCategoryId,
        currentRegionId: currentRegionId,
        onApply: onApply,
      ),
    );
  }

  @override
  State<DealersFilterModal> createState() => _DealersFilterModalState();
}

class _DealersFilterModalState extends State<DealersFilterModal> {
  final CatalogApi _api = getIt<CatalogApi>();

  List<CategoryModel> _categories = [];
  List<RegionModel> _regions = [];
  bool _loading = true;

  int? _selectedCategoryId;
  int? _selectedRegionId;

  Map<int, List<CategoryModel>> _categoryChildren = {};
  Map<int, List<RegionModel>> _regionChildren = {};
  Set<int> _expandedCategoryIds = {};
  Set<int> _expandedRegionIds = {};

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.currentCategoryId;
    _selectedRegionId = widget.currentRegionId;
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final cats = await _api.getCategories(parentId: null);
      final regs = await _api.getRegions(parentId: null);
      if (mounted) {
        setState(() {
          _categories = cats;
          _regions = regs;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadCategoryChildren(int parentId) async {
    if (_categoryChildren.containsKey(parentId)) return;
    try {
      final children = await _api.getCategories(parentId: parentId);
      if (mounted) setState(() => _categoryChildren[parentId] = children);
    } catch (_) {}
  }

  Future<void> _loadRegionChildren(int parentId) async {
    if (_regionChildren.containsKey(parentId)) return;
    try {
      final children = await _api.getRegions(parentId: parentId);
      if (mounted) setState(() => _regionChildren[parentId] = children);
    } catch (_) {}
  }

  void _onApply() {
    widget.onApply(
      categoryId: _selectedCategoryId,
      regionId: _selectedRegionId,
    );
    Navigator.of(context).pop();
  }

  void _onClear() {
    setState(() {
      _selectedCategoryId = null;
      _selectedRegionId = null;
      _expandedCategoryIds.clear();
      _expandedRegionIds.clear();
    });
    widget.onApply(categoryId: null, regionId: null);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.25,
      maxChildSize: 0.85,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHandle(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.filter,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkNavy,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _onClear,
                      child: Text(
                        AppLocalizations.of(context)!.filterClear,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.grayText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_loading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.darkNavy),
                  ),
                )
              else
                Expanded(
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: AppColors.graySubtle.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TabBar(
                            labelColor: AppColors.darkNavy,
                            unselectedLabelColor: AppColors.grayText,
                            indicator: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            indicatorSize: TabBarIndicatorSize.tab,
                            dividerColor: Colors.transparent,
                            labelStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            padding: const EdgeInsets.all(4),
                            tabs: [
                              Tab(
                                  text: AppLocalizations.of(context)!
                                      .filterCategory),
                              Tab(
                                  text: AppLocalizations.of(context)!
                                      .filterRegion),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildCategoryTab(),
                              _buildRegionTab(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              _buildApplyButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      children: _categories.map((c) => _buildCategoryItem(c, 0)).toList(),
    );
  }

  Widget _buildRegionTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      children: _regions.map((r) => _buildRegionItem(r, 0)).toList(),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.graySubtle,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildApplyButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        20 + MediaQuery.of(context).padding.bottom,
      ),
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
    );
  }

  Widget _buildCategoryItem(CategoryModel cat, int depth) {
    final hasChildren = cat.hasChildren;
    final isExpanded = _expandedCategoryIds.contains(cat.id);
    final children = _categoryChildren[cat.id];
    final isSelected = _selectedCategoryId == cat.id;

    return _TreeRow(
      depth: depth,
      label: cat.name,
      isSelected: isSelected,
      hasChildren: hasChildren,
      isExpanded: isExpanded,
      onRowTap: () {
        if (hasChildren && !isExpanded) {
          setState(() {
            _expandedCategoryIds.add(cat.id);
            _loadCategoryChildren(cat.id);
          });
        } else {
          setState(() =>
              _selectedCategoryId = _selectedCategoryId == cat.id ? null : cat.id);
        }
      },
      onExpand: hasChildren
          ? () {
              setState(() {
                if (isExpanded) {
                  _expandedCategoryIds.remove(cat.id);
                } else {
                  _expandedCategoryIds.add(cat.id);
                  _loadCategoryChildren(cat.id);
                }
              });
            }
          : null,
      child: isExpanded && children != null && children.isNotEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children
                  .map((c) => _buildCategoryItem(c, depth + 1))
                  .toList(),
            )
          : null,
    );
  }

  Widget _buildRegionItem(RegionModel reg, int depth) {
    final hasChildren = reg.hasChildren;
    final isExpanded = _expandedRegionIds.contains(reg.id);
    final children = _regionChildren[reg.id];
    final isSelected = _selectedRegionId == reg.id;

    return _TreeRow(
      depth: depth,
      label: reg.name,
      isSelected: isSelected,
      hasChildren: hasChildren,
      isExpanded: isExpanded,
      onRowTap: () {
        if (hasChildren && !isExpanded) {
          setState(() {
            _expandedRegionIds.add(reg.id);
            _loadRegionChildren(reg.id);
          });
        } else {
          setState(() =>
              _selectedRegionId = _selectedRegionId == reg.id ? null : reg.id);
        }
      },
      onExpand: hasChildren
          ? () {
              setState(() {
                if (isExpanded) {
                  _expandedRegionIds.remove(reg.id);
                } else {
                  _expandedRegionIds.add(reg.id);
                  _loadRegionChildren(reg.id);
                }
              });
            }
          : null,
      child: isExpanded && children != null && children.isNotEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children:
                  children.map((r) => _buildRegionItem(r, depth + 1)).toList(),
            )
          : null,
    );
  }
}

class _TreeRow extends StatelessWidget {
  const _TreeRow({
    required this.depth,
    required this.label,
    required this.isSelected,
    required this.hasChildren,
    required this.isExpanded,
    required this.onRowTap,
    this.onExpand,
    this.child,
  });

  final int depth;
  final String label;
  final bool isSelected;
  final bool hasChildren;
  final bool isExpanded;
  final VoidCallback onRowTap;
  final VoidCallback? onExpand;
  final Widget? child;

  static const _indentPerLevel = 20.0;
  static const _expandHitSize = 40.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(left: (depth * _indentPerLevel)),
          child: Row(
            children: [
              SizedBox(
                width: _expandHitSize,
                height: 44,
                child: hasChildren && onExpand != null
                    ? Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onExpand,
                          borderRadius: BorderRadius.circular(8),
                          child: Icon(
                            isExpanded
                                ? Icons.expand_more
                                : Icons.chevron_right,
                            color: AppColors.grayText,
                            size: 26,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              Expanded(
                child: Material(
                  color: isSelected
                      ? AppColors.gold.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: onRowTap,
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppColors.darkNavy
                                    : AppColors.grayText,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.gold,
                              size: 22,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (child != null) child!,
      ],
    );
  }
}
