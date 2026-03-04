import 'package:sement_market_customer/core/api/api_client.dart';
import 'package:sement_market_customer/core/di/injection.dart';
import 'package:sement_market_customer/features/dealers/data/models/brand_model.dart';
import 'package:sement_market_customer/features/dealers/data/models/category_model.dart';
import 'package:sement_market_customer/features/dealers/data/models/region_model.dart';

/// API for shared catalog data like categories, regions, and brands.
/// Implements caching to reduce redundant network calls.
class CatalogApi {
  CatalogApi([ApiClient? client]) : _client = client ?? getIt<ApiClient>();

  final ApiClient _client;

  // Cache fields
  List<CategoryModel>? _rootCategoriesCache;
  List<RegionModel>? _rootRegionsCache;
  final Map<int, List<BrandModel>> _warehouseBrandsCache = {};

  /// Clears all cached data. Useful for pull-to-refresh.
  void clearCache() {
    _rootCategoriesCache = null;
    _rootRegionsCache = null;
    _warehouseBrandsCache.clear();
  }

  Future<List<CategoryModel>> getCategories({int? parentId}) async {
    // Return cached root categories if available
    if (parentId == null && _rootCategoriesCache != null) {
      return _rootCategoriesCache!;
    }

    final params = <String, dynamic>{};
    params['filter[parent_id]'] = parentId == null ? 'null' : parentId.toString();

    final r = await _client.dio.get('/categories', queryParameters: params);
    final data = (r.data as Map<String, dynamic>)['data'] as List<dynamic>? ?? [];

    final result = data
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();

    // Cache root categories
    if (parentId == null) {
      _rootCategoriesCache = result;
    }

    return result;
  }

  Future<List<RegionModel>> getRegions({int? parentId}) async {
    // Return cached root regions if available
    if (parentId == null && _rootRegionsCache != null) {
      return _rootRegionsCache!;
    }

    final params = <String, dynamic>{};
    params['filter[parent_id]'] = parentId == null ? 'null' : parentId.toString();

    final r = await _client.dio.get('/regions', queryParameters: params);
    final data = (r.data as Map<String, dynamic>)['data'] as List<dynamic>? ?? [];

    final result = data
        .map((e) => RegionModel.fromJson(e as Map<String, dynamic>))
        .toList();

    // Cache root regions
    if (parentId == null) {
      _rootRegionsCache = result;
    }

    return result;
  }

  Future<List<BrandModel>> getWarehouseBrands(int warehouseId) async {
    // Return cached brands for this warehouse if available
    if (_warehouseBrandsCache.containsKey(warehouseId)) {
      return _warehouseBrandsCache[warehouseId]!;
    }

    final r = await _client.dio.get('/warehouses/$warehouseId/brands');
    final data = (r.data as Map<String, dynamic>)['data'] as List<dynamic>? ?? [];

    final result = data
        .map((e) => BrandModel.fromJson(e as Map<String, dynamic>))
        .toList();

    // Cache brands for this warehouse
    _warehouseBrandsCache[warehouseId] = result;

    return result;
  }
}
