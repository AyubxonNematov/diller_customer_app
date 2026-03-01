import 'package:sement_market_customer/core/api/api_client.dart';
import 'package:sement_market_customer/core/di/injection.dart';
import 'package:sement_market_customer/features/dealers/data/models/category_model.dart';
import 'package:sement_market_customer/features/dealers/data/models/paginated_dealers_response.dart';
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

  Future<List<CategoryModel>> getCategories() async {
    final r = await _client.dio.get('/categories');
    final data = (r.data as Map<String, dynamic>)['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<CategoryModel>> getCategoryChildren(int parentId) async {
    final r = await _client.dio.get('/categories/$parentId/children');
    final data = (r.data as Map<String, dynamic>)['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<RegionModel>> getRegions() async {
    final r = await _client.dio.get('/regions');
    final data = (r.data as Map<String, dynamic>)['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => RegionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<RegionModel>> getRegionChildren(int parentId) async {
    final r = await _client.dio.get('/regions/$parentId/children');
    final data = (r.data as Map<String, dynamic>)['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => RegionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
