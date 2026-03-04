import 'package:sement_market_customer/core/api/api_client.dart';
import 'package:sement_market_customer/core/di/injection.dart';
import 'package:sement_market_customer/features/dealers/data/models/paginated_dealers_response.dart';
import 'package:sement_market_customer/features/dealers/data/models/paginated_warehouses_response.dart';

/// API for dealer and warehouse-related operations.
class DealersApi {
  DealersApi([ApiClient? client]) : _client = client ?? getIt<ApiClient>();

  final ApiClient _client;

  Future<PaginatedDealersResponse> getDealers({
    int? categoryId,
    int? regionId,
    String? location,
    String? search,
    int page = 1,
  }) async {
    final params = <String, dynamic>{
      'page': page,
    };
    if (categoryId != null) params['filter[category_id]'] = categoryId;
    if (regionId != null) params['filter[region]'] = regionId;
    if (location != null && location.isNotEmpty) {
      params['filter[location]'] = location;
    }
    if (search != null && search.trim().isNotEmpty) {
      params['filter[search]'] = search.trim();
    }

    final r = await _client.dio.get(
      '/dealers',
      queryParameters: params,
    );
    return PaginatedDealersResponse.fromJson(
      r.data as Map<String, dynamic>,
    );
  }

  Future<PaginatedWarehousesResponse> getWarehouses({
    required int dealerId,
    String? search,
    String? location,
    int page = 1,
  }) async {
    final params = <String, dynamic>{'page': page};
    if (location != null && location.isNotEmpty) {
      params['filter[location]'] = location;
    }
    if (search != null && search.trim().isNotEmpty) {
      params['filter[search]'] = search.trim();
    }
    final r = await _client.dio.get(
      '/dealers/$dealerId/warehouses',
      queryParameters: params,
    );
    return PaginatedWarehousesResponse.fromJson(
      r.data as Map<String, dynamic>,
    );
  }
}

