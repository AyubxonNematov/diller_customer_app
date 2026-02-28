import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sement_market_customer/core/debug/alice_setup.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  ApiClient({required String baseUrl}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
    ));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (e, handler) {
        if (e.response?.statusCode == 401) {
          // Clear token and go to login
        }
        return handler.next(e);
      },
    ));
    if (kDebugMode) {
      final aliceInterceptor = aliceDioInterceptor;
      if (aliceInterceptor != null) {
        _dio.interceptors.add(aliceInterceptor);
      }
    }
  }

  late final Dio _dio;
  Dio get dio => _dio;

  static const _defaultBaseUrl = 'http://10.13.81.70:8000/customers/v1';

  static ApiClient create([String? baseUrl]) {
    return ApiClient(baseUrl: baseUrl ?? _defaultBaseUrl);
  }
}
