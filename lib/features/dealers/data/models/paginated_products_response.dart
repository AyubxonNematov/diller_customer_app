import 'package:equatable/equatable.dart';

import 'product_model.dart';
import 'paginated_dealers_response.dart';

class PaginatedProductsResponse extends Equatable {
  const PaginatedProductsResponse({
    required this.data,
    required this.meta,
    required this.links,
  });

  final List<ProductModel> data;
  final PaginationMeta meta;
  final PaginationLinks links;

  @override
  List<Object?> get props => [data, meta, links];

  factory PaginatedProductsResponse.fromJson(Map<String, dynamic> json) {
    final raw = (json['data'] as List<dynamic>?) ?? [];
    final data = raw
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return PaginatedProductsResponse(
      data: data,
      meta: PaginationMeta.fromJson(
        (json['meta'] as Map<String, dynamic>?) ?? {},
      ),
      links: PaginationLinks.fromJson(
        (json['links'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }
}
