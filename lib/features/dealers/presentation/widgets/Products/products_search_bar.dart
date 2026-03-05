import 'package:flutter/material.dart';
import 'package:sement_market_customer/core/theme/app_theme.dart';
import 'package:sement_market_customer/l10n/app_localizations.dart';

class ProductsSearchBar extends StatefulWidget {
  const ProductsSearchBar({
    super.key,
    required this.onChanged,
    required this.onFilterTap,
    this.searchQuery,
    this.activeFiltersCount = 0,
  });

  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;
  final String? searchQuery;
  final int activeFiltersCount;

  @override
  State<ProductsSearchBar> createState() => _ProductsSearchBarState();
}

class _ProductsSearchBarState extends State<ProductsSearchBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchQuery ?? '');
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(ProductsSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery &&
        widget.searchQuery != _controller.text) {
      _controller.text = widget.searchQuery ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onClear() {
    _controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final hasText = _controller.text.isNotEmpty;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: widget.onChanged,
                  style: const TextStyle(
                    color: AppColors.darkNavy,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        AppLocalizations.of(context)!.productSearchHint,
                    hintStyle: TextStyle(
                      color: AppColors.grayText.withValues(alpha: 0.8),
                      fontSize: 15,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AppColors.grayText.withValues(alpha: 0.7),
                      size: 22,
                    ),
                    suffixIcon: hasText
                        ? IconButton(
                            icon: Icon(
                              Icons.cancel_rounded,
                              color: AppColors.grayText.withValues(alpha: 0.7),
                              size: 20,
                            ),
                            onPressed: _onClear,
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onFilterTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: widget.activeFiltersCount > 0
                          ? AppColors.darkNavy
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Center(
                          child: Icon(
                            Icons.tune_rounded,
                            size: 24,
                            color: widget.activeFiltersCount > 0
                                ? Colors.white
                                : AppColors.grayText,
                          ),
                        ),
                        if (widget.activeFiltersCount > 0)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                color: AppColors.gold,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${widget.activeFiltersCount}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.darkNavy,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
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
