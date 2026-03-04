import 'package:equatable/equatable.dart';

import 'warehouse_model.dart';
import 'paginated_dealers_response.dart';

class PaginatedWarehousesResponse extends Equatable {
  const PaginatedWarehousesResponse({
    required this.data,
    required this.meta,
  });

  final List<WarehouseModel> data;
  final PaginationMeta meta;

  @override
  List<Object?> get props => [data, meta];

  factory PaginatedWarehousesResponse.fromJson(Map<String, dynamic> json) {
    final raw = (json['data'] as List<dynamic>?) ?? [];
    return PaginatedWarehousesResponse(
      data: raw
          .map((e) => WarehouseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: PaginationMeta.fromJson(
        (json['meta'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }
}
