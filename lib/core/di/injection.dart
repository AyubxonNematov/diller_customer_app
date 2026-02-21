import 'package:get_it/get_it.dart';
import 'package:sement_market_customer/core/api/api_client.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  getIt.registerSingleton<ApiClient>(ApiClient.create());
}
