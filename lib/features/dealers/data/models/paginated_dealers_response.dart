import 'package:equatable/equatable.dart';

import 'dealer_model.dart';

class PaginatedDealersResponse extends Equatable {
  const PaginatedDealersResponse({
    required this.data,
    required this.meta,
  });

  final List<DealerModel> data;
  final PaginationMeta meta;

  @override
  List<Object?> get props => [data, meta];

  factory PaginatedDealersResponse.fromJson(Map<String, dynamic> json) {
    final raw = (json['data'] as List<dynamic>?) ?? [];
    return PaginatedDealersResponse(
      data: raw
          .map((e) => DealerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: PaginationMeta.fromJson(
        (json['meta'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }
}

class PaginationMeta {
  const PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
      perPage: json['per_page'] as int? ?? 15,
      total: json['total'] as int? ?? 0,
    );
  }
}
