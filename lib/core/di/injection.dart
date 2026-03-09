import 'package:get_it/get_it.dart';
import 'package:sement_market_customer/core/api/api_client.dart';
import 'package:sement_market_customer/core/api/catalog_api.dart';
import 'package:sement_market_customer/core/locale/app_locale.dart';
import 'package:sement_market_customer/features/dealers/data/dealers_api.dart';
import 'package:sement_market_customer/features/dealers/data/products_api.dart';
import 'package:sement_market_customer/features/orders/data/orders_api.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  getIt.registerSingleton<ApiClient>(ApiClient.create());
  getIt.registerSingleton<CatalogApi>(CatalogApi());
  getIt.registerSingleton<DealersApi>(DealersApi());
  getIt.registerSingleton<ProductsApi>(ProductsApi());
  getIt.registerSingleton<OrdersApi>(OrdersApi());
  final appLocale = AppLocale();
  await appLocale.ensureLoaded();
  getIt.registerSingleton<AppLocale>(appLocale);
}
