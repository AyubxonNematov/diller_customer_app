import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
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
      if (kDebugMode && token != null) {
        debugPrint('[FCM] Token olindi, backendga yuborilmoqda...');
      }
      if (token != null) {
        await _sendFcmTokenToBackend(token);
      }
      messaging.onTokenRefresh.listen((newToken) {
        _sendFcmTokenToBackend(newToken);
      });
      FirebaseMessaging.onMessage.listen((_) {});
      FirebaseMessaging.onMessageOpenedApp.listen((_) {});
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    } catch (e, st) {
      if (kDebugMode) debugPrint('[FCM] init xato: $e\n$st');
    }
  }

  /// Ilovaga kirganda (auth mavjud bo'lsa) FCM token va device_info ni backendga yuboradi
  static Future<void> sendFcmTokenIfAuthenticated() async {
    if (Firebase.apps.isEmpty) return; // Firebase init bo'lmagan (masalan, google-services.json yo'q)
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _sendFcmTokenToBackend(token);
      } else if (kDebugMode) {
        debugPrint('[FCM] getToken() null qaytardi');
      }
    } catch (e, st) {
      if (kDebugMode) debugPrint('[FCM] sendFcmTokenIfAuthenticated xato: $e\n$st');
    }
  }

  static Future<void> _sendFcmTokenToBackend(String fcmToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');
      if (authToken == null) {
        if (kDebugMode) debugPrint('[FCM] auth_token yo\'q, yuborilmaydi');
        return;
      }
      final api = getIt<ApiClient>();
      final deviceInfo = _getDeviceInfo();
      await api.dio.put('/me/fcm-token', data: {
        'fcm_token': fcmToken,
        'device_info': deviceInfo,
      });
      if (kDebugMode) debugPrint('[FCM] backendga muvaffaqiyatli yuborildi');
    } on DioException catch (e, st) {
      if (kDebugMode) {
        debugPrint('[FCM] PUT /me/fcm-token xato: ${e.response?.statusCode} ${e.response?.data}\n$st');
      }
    } catch (e, st) {
      if (kDebugMode) debugPrint('[FCM] _sendFcmTokenToBackend xato: $e\n$st');
    }
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
