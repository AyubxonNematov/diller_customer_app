import 'package:alice/alice.dart';
import 'package:alice/model/alice_configuration.dart';
import 'package:alice_dio/alice_dio_adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Debug rejimda Alice HTTP Inspector uchun sozlama.
final navigatorKey = GlobalKey<NavigatorState>();

Alice? _alice;
AliceDioAdapter? _aliceDioAdapter;

/// Alice instance (faqat debug rejimda).
Alice? get alice => _alice;

/// Dio uchun Alice interceptor (faqat debug rejimda).
Interceptor? get aliceDioInterceptor {
  if (!kDebugMode) return null;
  if (_aliceDioAdapter != null) return _aliceDioAdapter;
  _alice = Alice(
    configuration: AliceConfiguration(navigatorKey: navigatorKey),
  );
  _aliceDioAdapter = AliceDioAdapter();
  _alice!.addAdapter(_aliceDioAdapter!);
  return _aliceDioAdapter;
}
