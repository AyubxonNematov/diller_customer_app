import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sement_market_customer/core/di/injection.dart';
import 'package:sement_market_customer/core/locale/app_locale.dart';
import 'package:sement_market_customer/core/theme/app_theme.dart';
import 'package:sement_market_customer/l10n/app_localizations.dart';
import 'language_selector.dart';

class ProfileSettingsSection extends StatelessWidget {
  const ProfileSettingsSection({super.key, required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final appLocale = getIt<AppLocale>();
    return ListenableBuilder(
      listenable: appLocale,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.settings_rounded,
                        color: AppColors.darkNavy,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.settings,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkNavy,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ProfileSettingsTile(
                icon: Icons.language_rounded,
                title: l10n.language,
                trailing: LanguageSelector(
                  l10n: l10n,
                  appLocale: appLocale,
                ),
              ),
              const Divider(height: 1, indent: 56, endIndent: 20),
              ProfileSettingsTile(
                icon: Icons.notifications_outlined,
                title: l10n.notificationsSettings,
                onTap: () => context.go('/notifications'),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.grayText,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class ProfileSettingsTile extends StatelessWidget {
  const ProfileSettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.darkNavy, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkNavy,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
