import 'package:flutter/material.dart';
import 'package:sement_market_customer/core/theme/app_theme.dart';
import 'package:sement_market_customer/l10n/app_localizations.dart';

class ProfileRulesSection extends StatelessWidget {
  const ProfileRulesSection({super.key, required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.salaryRules,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.darkNavy,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            _RuleItem(text: l10n.rule1),
            const SizedBox(height: 12),
            _RuleItem(text: l10n.rule2),
            const SizedBox(height: 12),
            _RuleItem(text: l10n.rule3, bold: true),
          ],
        ),
      ),
    );
  }
}

class _RuleItem extends StatelessWidget {
  const _RuleItem({required this.text, this.bold = false});
  final String text;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.darkNavy,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.darkNavy,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
