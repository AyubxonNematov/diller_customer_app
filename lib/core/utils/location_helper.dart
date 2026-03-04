import 'package:geolocator/geolocator.dart';

/// Centralized geolocation helper — eliminates duplicated location code.
class LocationHelper {
  static String? _cachedLocation;

  /// Returns `"lat,lng"` string or `null` if permission denied or error.
  /// Optimized for speed: returns cached location if available, otherwise tries last known position, then requests current with timeout.
  static Future<String?> getCurrentLocation({bool forceRefresh = false}) async {
    if (_cachedLocation != null && !forceRefresh) {
      return _cachedLocation;
    }

    try {
      final status = await Geolocator.checkPermission();
      if (status == LocationPermission.denied ||
          status == LocationPermission.deniedForever ||
          status == LocationPermission.unableToDetermine) {
        return null;
      }

      // 1. Try last known position (near-instant)
      final lastPos = await Geolocator.getLastKnownPosition();
      if (lastPos != null) {
        _cachedLocation = '${lastPos.latitude},${lastPos.longitude}';
        return _cachedLocation;
      }

      // 2. Request current position with strict timeout (3 seconds)
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low, // Lower accuracy is faster
          timeLimit: Duration(seconds: 3),
        ),
      );
      _cachedLocation = '${pos.latitude},${pos.longitude}';
      return _cachedLocation;
    } catch (_) {
      return null;
    }
  }

  /// Clears the cached location. Use if manual refresh is needed.
  static void clearCache() => _cachedLocation = null;

  /// Checks permission status for showing dialog in UI.
  static Future<LocationPermission> checkPermission() async {
    return Geolocator.checkPermission();
  }
}
