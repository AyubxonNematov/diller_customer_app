import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sement_market_customer/l10n/app_localizations.dart';

class LocationPermissionDialog extends StatelessWidget {
  final bool deniedForever;

  const LocationPermissionDialog({
    super.key,
    required this.deniedForever,
  });

  static void show(BuildContext context, {required bool deniedForever}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => LocationPermissionDialog(deniedForever: deniedForever),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFF4C400).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on,
              color: Color(0xFFF4C400),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.locationPermission,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0E1A33),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.locationDesc,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF9EA6B3),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0E1A33),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                if (deniedForever) {
                  await Geolocator.openAppSettings();
                } else {
                  await Geolocator.requestPermission();
                }
              },
              child: Text(
                deniedForever
                    ? AppLocalizations.of(context)!.openSettings
                    : AppLocalizations.of(context)!.grantPermission,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              AppLocalizations.of(context)!.later,
              style: const TextStyle(color: Color(0xFF9EA6B3)),
            ),
          ),
        ],
      ),
    );
  }
}
