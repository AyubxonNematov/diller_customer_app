import 'package:flutter/material.dart';
import 'package:sement_market_customer/app.dart';
import 'package:sement_market_customer/core/di/injection.dart';
import 'package:sement_market_customer/core/firebase/firebase_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  await FirebaseNotificationsService.init();
  runApp(const SementMarketCustomerApp());
}
