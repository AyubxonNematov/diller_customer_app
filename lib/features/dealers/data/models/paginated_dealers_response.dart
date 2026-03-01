import 'package:equatable/equatable.dart';

import 'dealer_model.dart';

class PaginatedDealersResponse extends Equatable {
  final List<DealerModel> data;
  final PaginationMeta meta;
  final PaginationLinks links;

  const PaginatedDealersResponse({
    required this.data,
    required this.meta,
    required this.links,
  });

  @override
  List<Object?> get props => [data, meta, links];

  factory PaginatedDealersResponse.fromJson(Map<String, dynamic> json) {
    final raw = (json['data'] as List<dynamic>?) ?? [];
    final data = raw
        .map((e) => DealerModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return PaginatedDealersResponse(
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

class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
      perPage: json['per_page'] as int? ?? 15,
      total: json['total'] as int? ?? 0,
    );
  }
}

class PaginationLinks {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  const PaginationLinks({
    this.first,
    this.last,
    this.prev,
    this.next,
  });

  factory PaginationLinks.fromJson(Map<String, dynamic> json) {
    return PaginationLinks(
      first: json['first'] as String?,
      last: json['last'] as String?,
      prev: json['prev'] as String?,
      next: json['next'] as String?,
    );
  }
}
