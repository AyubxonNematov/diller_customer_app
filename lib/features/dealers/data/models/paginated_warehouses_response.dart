import 'package:equatable/equatable.dart';

import 'warehouse_model.dart';
import 'paginated_dealers_response.dart';

class PaginatedWarehousesResponse extends Equatable {
  const PaginatedWarehousesResponse({
    required this.data,
    required this.meta,
    required this.links,
  });

  final List<WarehouseModel> data;
  final PaginationMeta meta;
  final PaginationLinks links;

  @override
  List<Object?> get props => [data, meta, links];

  factory PaginatedWarehousesResponse.fromJson(Map<String, dynamic> json) {
    final raw = (json['data'] as List<dynamic>?) ?? [];
    final data = raw
        .map((e) => WarehouseModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return PaginatedWarehousesResponse(
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
