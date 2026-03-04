import 'package:flutter/material.dart';
import 'package:sement_market_customer/core/locale/app_locale.dart';
import 'package:sement_market_customer/core/theme/app_theme.dart';
import 'package:sement_market_customer/l10n/app_localizations.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({
    super.key,
    required this.l10n,
    required this.appLocale,
  });
  final AppLocalizations l10n;
  final AppLocale appLocale;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LanguageChip(
          label: l10n.langUz,
          selected: appLocale.isUz,
          onTap: () => appLocale.setUz(),
        ),
        const SizedBox(width: 8),
        _LanguageChip(
          label: l10n.langRu,
          selected: appLocale.isRu,
          onTap: () => appLocale.setRu(),
        ),
      ],
    );
  }
}

class _LanguageChip extends StatelessWidget {
  const _LanguageChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.darkNavy : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.darkNavy : AppColors.graySubtle,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppColors.grayText,
          ),
        ),
      ),
    );
  }
}
