import 'package:equatable/equatable.dart';

import 'product_model.dart';
import 'paginated_dealers_response.dart';

class PaginatedProductsResponse extends Equatable {
  const PaginatedProductsResponse({
    required this.data,
    required this.meta,
  });

  final List<ProductModel> data;
  final PaginationMeta meta;

  @override
  List<Object?> get props => [data, meta];

  factory PaginatedProductsResponse.fromJson(Map<String, dynamic> json) {
    final raw = (json['data'] as List<dynamic>?) ?? [];
    return PaginatedProductsResponse(
      data: raw
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: PaginationMeta.fromJson(
        (json['meta'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }
}
