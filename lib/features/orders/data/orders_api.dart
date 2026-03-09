import 'package:sement_market_customer/core/api/api_client.dart';
import 'package:sement_market_customer/core/di/injection.dart';
import 'package:sement_market_customer/features/orders/data/models/order_model.dart';
import 'package:sement_market_customer/features/orders/data/models/paginated_orders_response.dart';

class OrdersApi {
  OrdersApi([ApiClient? client]) : _client = client ?? getIt<ApiClient>();

  final ApiClient _client;

  Future<PaginatedOrdersResponse> getOrders({
    int page = 1,
    int perPage = 15,
  }) async {
    final r = await _client.dio.get(
      '/orders',
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
    );
    return PaginatedOrdersResponse.fromJson(r.data as Map<String, dynamic>);
  }

  Future<OrderModel> getOrder(int id) async {
    final r = await _client.dio.get('/orders/$id');
    final data = r.data is Map<String, dynamic>
        ? r.data as Map<String, dynamic>
        : <String, dynamic>{};
    // API resource wraps in "data" key
    final orderJson = data.containsKey('data')
        ? (data['data'] as Map).cast<String, dynamic>()
        : data;
    return OrderModel.fromJson(orderJson);
  }

  /// POST /orders — place a new order
  Future<OrderModel> createOrder({
    required int warehouseId,
    required String deliveryType,
    required List<Map<String, dynamic>> items,
  }) async {
    final r = await _client.dio.post(
      '/orders',
      data: {
        'warehouse_id': warehouseId,
        'delivery_type': deliveryType,
        'items': items,
      },
    );
    final data = r.data is Map<String, dynamic>
        ? r.data as Map<String, dynamic>
        : <String, dynamic>{};
    final orderJson = data.containsKey('data')
        ? (data['data'] as Map).cast<String, dynamic>()
        : data;
    return OrderModel.fromJson(orderJson);
  }
}
