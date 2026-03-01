import 'package:flutter/material.dart';
import 'package:sement_market_customer/core/theme/app_theme.dart';
import 'package:sement_market_customer/l10n/app_localizations.dart';

class DealersEmptyState extends StatelessWidget {
  const DealersEmptyState({
    super.key,
    this.onRetry,
    this.onClearFilters,
    this.hasActiveFilters = false,
    this.emptyTitle,
    this.emptyHint,
  });

  final VoidCallback? onRetry;
  final VoidCallback? onClearFilters;
  final bool hasActiveFilters;
  final String? emptyTitle;
  final String? emptyHint;

  @override
  Widget build(BuildContext context) {
    final showClearFilters = hasActiveFilters && onClearFilters != null;
    final showRetry = !showClearFilters && onRetry != null;
    final title = emptyTitle ?? AppLocalizations.of(context)!.dealersEmpty;
    final hint = emptyHint ?? AppLocalizations.of(context)!.dealersEmptyHint;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.goldLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.store_outlined,
                size: 48,
                color: AppColors.gold.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.darkNavy,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              hint,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grayText,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (showClearFilters) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(Icons.filter_alt_off_rounded, size: 20),
                label: Text(AppLocalizations.of(context)!.clearFiltersShowAll),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.darkNavy,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ] else if (showRetry) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 20),
                label: Text(AppLocalizations.of(context)!.retry),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.darkNavy,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
