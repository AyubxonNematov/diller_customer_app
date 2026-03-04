import 'package:sement_market_customer/core/api/api_client.dart';
import 'package:sement_market_customer/core/di/injection.dart';
import 'package:sement_market_customer/features/dealers/data/models/paginated_products_response.dart';

/// API for product-related operations.
class ProductsApi {
  ProductsApi([ApiClient? client]) : _client = client ?? getIt<ApiClient>();

  final ApiClient _client;

  Future<PaginatedProductsResponse> getProducts({
    required int warehouseId,
    String? search,
    int? brandId,
    String? sort,
    int page = 1,
  }) async {
    final params = <String, dynamic>{'page': page};
    if (search != null && search.trim().isNotEmpty) {
      params['filter[search]'] = search.trim();
    }
    if (brandId != null) params['filter[brand_id]'] = brandId;
    if (sort != null && sort.isNotEmpty) params['sort'] = sort;

    final r = await _client.dio.get(
      '/warehouses/$warehouseId/products',
      queryParameters: params,
    );
    return PaginatedProductsResponse.fromJson(
      r.data as Map<String, dynamic>,
    );
  }
}
