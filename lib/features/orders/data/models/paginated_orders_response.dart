import 'package:equatable/equatable.dart';
import 'package:sement_market_customer/features/dealers/data/models/paginated_dealers_response.dart';
import 'package:sement_market_customer/features/orders/data/models/order_model.dart';

class PaginatedOrdersResponse extends Equatable {
  const PaginatedOrdersResponse({
    required this.data,
    required this.meta,
  });

  final List<OrderModel> data;
  final PaginationMeta meta;

  @override
  List<Object?> get props => [data, meta];

  factory PaginatedOrdersResponse.fromJson(Map<String, dynamic> json) {
    final raw = (json['data'] as List<dynamic>?) ?? [];
    return PaginatedOrdersResponse(
      data: raw
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: PaginationMeta.fromJson(
        (json['meta'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }
}
