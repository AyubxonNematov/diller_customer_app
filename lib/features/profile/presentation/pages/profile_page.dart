import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sement_market_customer/core/theme/app_theme.dart';
import 'package:sement_market_customer/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:sement_market_customer/features/profile/presentation/widgets/profile_balance_card.dart';
import 'package:sement_market_customer/features/profile/presentation/widgets/profile_header.dart';
import 'package:sement_market_customer/features/profile/presentation/widgets/profile_rules_section.dart';
import 'package:sement_market_customer/features/profile/presentation/widgets/profile_settings_section.dart';
import 'package:sement_market_customer/l10n/app_localizations.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileLoggedOut) {
              context.go('/login');
            }
          },
          buildWhen: (prev, curr) => curr is! ProfileLoggedOut,
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.darkNavy),
              );
            }
            if (state is ProfileError) {
              return _buildError(context, state.message);
            }
            if (state is ProfileLoaded) {
              return _buildContent(context, state.user);
            }
            return const Center(
              child: CircularProgressIndicator(color: AppColors.darkNavy),
            );
          },
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.grayText),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.grayText)),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () =>
                  context.read<ProfileBloc>().add(const ProfileLoad()),
              child: Text(AppLocalizations.of(context)!.retry),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context
                  .read<ProfileBloc>()
                  .add(const ProfileLogoutRequested()),
              child: Text(AppLocalizations.of(context)!.logout),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Map<String, dynamic> user) {
    final l10n = AppLocalizations.of(context)!;
    final name = user['name'] ?? l10n.user;
    final phone = user['phone'] ?? '';
    final balance = user['balance'] ?? '0';

    return RefreshIndicator(
      onRefresh: () => context.read<ProfileBloc>().refresh(),
      color: AppColors.darkNavy,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileHeader(
              l10n: l10n,
              name: name,
              balance: balance,
              onLogout: () => context
                  .read<ProfileBloc>()
                  .add(const ProfileLogoutRequested()),
            ),
            const SizedBox(height: 20),
            ProfileBalanceCard(
              l10n: l10n,
              balance: balance,
              phone: phone,
            ),
            const SizedBox(height: 28),
            ProfileRulesSection(l10n: l10n),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ProfileSettingsSection(l10n: l10n),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
