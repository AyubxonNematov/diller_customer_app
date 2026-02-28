import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sement_market_customer/core/api/api_client.dart';
import 'package:sement_market_customer/core/di/injection.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class FirebaseNotificationsService {
  static Future<void> init() async {
    try {
      await Firebase.initializeApp();
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();
      final token = await messaging.getToken();
      if (token != null) {
        await _sendFcmTokenToBackend(token);
      }
      messaging.onTokenRefresh.listen((newToken) {
        _sendFcmTokenToBackend(newToken);
      });
      FirebaseMessaging.onMessage.listen((_) {});
      FirebaseMessaging.onMessageOpenedApp.listen((_) {});
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    } catch (_) {}
  }

  /// Authenticationdan o'tgan bo'lsa FCM token va device_info ni backendga yuboradi
  static Future<void> sendFcmTokenIfAuthenticated() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) await _sendFcmTokenToBackend(token);
    } catch (_) {}
  }

  static Future<void> _sendFcmTokenToBackend(String fcmToken) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('auth_token') == null) return;
    try {
      final api = getIt<ApiClient>();
      await api.dio.put('/me/fcm-token', data: {
        'fcm_token': fcmToken,
        'device_info': _getDeviceInfo(),
      });
    } catch (_) {}
  }

  static Map<String, String> _getDeviceInfo() {
    try {
      return {
        'platform': Platform.operatingSystem,
        'os_version': Platform.operatingSystemVersion,
      };
    } catch (_) {
      return {};
    }
  }
}
