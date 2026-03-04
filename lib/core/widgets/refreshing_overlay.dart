import 'package:flutter/material.dart';
import 'package:sement_market_customer/core/theme/app_theme.dart';

class RefreshingOverlay extends StatelessWidget {
  const RefreshingOverlay({
    super.key,
    required this.isRefreshing,
    required this.message,
  });

  final bool isRefreshing;
  final String message;

  @override
  Widget build(BuildContext context) {
    if (!isRefreshing) return const SizedBox.shrink();

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
        elevation: 0,
        color: Colors.white.withValues(alpha: 0.8),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.darkNavy,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.grayText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
