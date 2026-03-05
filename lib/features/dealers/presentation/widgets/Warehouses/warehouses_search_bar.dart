import 'package:flutter/material.dart';
import 'package:sement_market_customer/core/theme/app_theme.dart';
import 'package:sement_market_customer/l10n/app_localizations.dart';

class WarehousesSearchBar extends StatefulWidget {
  const WarehousesSearchBar({
    super.key,
    required this.onChanged,
    this.searchQuery,
  });

  final ValueChanged<String> onChanged;
  final String? searchQuery;

  @override
  State<WarehousesSearchBar> createState() => _WarehousesSearchBarState();
}

class _WarehousesSearchBarState extends State<WarehousesSearchBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchQuery ?? '');
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(WarehousesSearchBar oldWidget) {
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
              hintText: AppLocalizations.of(context)!.warehouseSearchHint,
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
        );
      },
    );
  }
}
