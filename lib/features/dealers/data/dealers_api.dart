import 'package:sement_market_customer/core/api/api_client.dart';
import 'package:sement_market_customer/core/di/injection.dart';
import 'package:sement_market_customer/features/dealers/data/models/category_model.dart';
import 'package:sement_market_customer/features/dealers/data/models/paginated_dealers_response.dart';
import 'package:sement_market_customer/features/dealers/data/models/paginated_warehouses_response.dart';
import 'package:sement_market_customer/features/dealers/data/models/region_model.dart';

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

  Future<List<CategoryModel>> getCategories({int? parentId}) async {
    final params = <String, dynamic>{};
    params['filter[parent_id]'] = parentId == null ? 'null' : parentId.toString();
    final r = await _client.dio.get('/categories', queryParameters: params);
    final data =
        (r.data as Map<String, dynamic>)['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<RegionModel>> getRegions({int? parentId}) async {
    final params = <String, dynamic>{};
    params['filter[parent_id]'] = parentId == null ? 'null' : parentId.toString();
    final r = await _client.dio.get('/regions', queryParameters: params);
    final data =
        (r.data as Map<String, dynamic>)['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => RegionModel.fromJson(e as Map<String, dynamic>))
        .toList();
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
