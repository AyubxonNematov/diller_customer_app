import 'package:flutter/material.dart';
import 'package:sement_market_customer/core/di/injection.dart';
import 'package:sement_market_customer/core/theme/app_theme.dart';
import 'package:sement_market_customer/features/dealers/data/dealers_api.dart';
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
  final DealersApi _api = getIt<DealersApi>();

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
      final cats = await _api.getCategories();
      final regs = await _api.getRegions();
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
      final children = await _api.getCategoryChildren(parentId);
      if (mounted) {
        setState(() => _categoryChildren[parentId] = children);
      }
    } catch (_) {}
  }

  Future<void> _loadRegionChildren(int parentId) async {
    if (_regionChildren.containsKey(parentId)) return;
    try {
      final children = await _api.getRegionChildren(parentId);
      if (mounted) {
        setState(() => _regionChildren[parentId] = children);
      }
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
    });
    widget.onApply(categoryId: null, regionId: null);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
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
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
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
            Flexible(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.darkNavy,
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSection(
                            title: AppLocalizations.of(context)!.filterCategory,
                            child: _buildCategoryList(_categories, depth: 0),
                          ),
                          const SizedBox(height: 20),
                          _buildSection(
                            title: AppLocalizations.of(context)!.filterRegion,
                            child: _buildRegionList(_regions, depth: 0),
                          ),
                        ],
                      ),
                    ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + MediaQuery.of(context).padding.bottom),
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
          ],
        ),
      ),
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

  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.darkNavy,
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }

  Widget _buildCategoryList(List<CategoryModel> items, {int depth = 0}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FilterTile(
          label: AppLocalizations.of(context)!.categoryAll,
          isSelected: _selectedCategoryId == null,
          onTap: () => setState(() => _selectedCategoryId = null),
        ),
        ...items.map((c) => _buildCategoryItem(c, depth)),
      ],
    );
  }

  Widget _buildCategoryItem(CategoryModel cat, int depth) {
    final hasChildren = cat.hasChildren;
    final isExpanded = _expandedCategoryIds.contains(cat.id);
    final children = _categoryChildren[cat.id];
    final isSelected = _selectedCategoryId == cat.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () {
            if (hasChildren) {
              setState(() {
                if (isExpanded) {
                  _expandedCategoryIds.remove(cat.id);
                } else {
                  _expandedCategoryIds.add(cat.id);
                  _loadCategoryChildren(cat.id);
                }
              });
            } else {
              setState(() => _selectedCategoryId = cat.id);
            }
          },
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: EdgeInsets.only(left: (depth * 16).toDouble(), right: 8, top: 8, bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    cat.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColors.darkNavy : AppColors.grayText,
                    ),
                  ),
                ),
                if (hasChildren)
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.grayText,
                    size: 24,
                  )
                else if (isSelected)
                  const Icon(Icons.check_circle, color: AppColors.gold, size: 22),
              ],
            ),
          ),
        ),
        if (isExpanded && children != null)
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: _buildCategoryList(children, depth: depth + 1),
          ),
      ],
    );
  }

  Widget _buildRegionList(List<RegionModel> items, {int depth = 0}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FilterTile(
          label: AppLocalizations.of(context)!.filterRegionAll,
          isSelected: _selectedRegionId == null,
          onTap: () => setState(() => _selectedRegionId = null),
        ),
        ...items.map((r) => _buildRegionItem(r, depth)),
      ],
    );
  }

  Widget _buildRegionItem(RegionModel reg, int depth) {
    final hasChildren = reg.hasChildren;
    final isExpanded = _expandedRegionIds.contains(reg.id);
    final children = _regionChildren[reg.id];
    final isSelected = _selectedRegionId == reg.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () {
            if (hasChildren) {
              setState(() {
                if (isExpanded) {
                  _expandedRegionIds.remove(reg.id);
                } else {
                  _expandedRegionIds.add(reg.id);
                  _loadRegionChildren(reg.id);
                }
              });
            } else {
              setState(() => _selectedRegionId = reg.id);
            }
          },
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: EdgeInsets.only(left: (depth * 16).toDouble(), right: 8, top: 8, bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    reg.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColors.darkNavy : AppColors.grayText,
                    ),
                  ),
                ),
                if (hasChildren)
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.grayText,
                    size: 24,
                  )
                else if (isSelected)
                  const Icon(Icons.check_circle, color: AppColors.gold, size: 22),
              ],
            ),
          ),
        ),
        if (isExpanded && children != null)
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: _buildRegionList(children, depth: depth + 1),
          ),
      ],
    );
  }
}

class _FilterTile extends StatelessWidget {
  const _FilterTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.darkNavy : AppColors.grayText,
                ),
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: AppColors.gold, size: 22),
          ],
        ),
      ),
    );
  }
}
