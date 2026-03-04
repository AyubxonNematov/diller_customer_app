import 'package:geolocator/geolocator.dart';

/// Centralized geolocation helper — eliminates duplicated location code.
class LocationHelper {
  /// Returns `"lat,lng"` string or `null` if permission denied or error.
  static Future<String?> getCurrentLocation() async {
    try {
      final status = await Geolocator.checkPermission();
      if (status == LocationPermission.denied ||
          status == LocationPermission.deniedForever ||
          status == LocationPermission.unableToDetermine) {
        return null;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      return '${pos.latitude},${pos.longitude}';
    } catch (_) {
      return null;
    }
  }

  /// Checks permission status for showing dialog in UI.
  static Future<LocationPermission> checkPermission() async {
    return Geolocator.checkPermission();
  }
}
