import 'package:equatable/equatable.dart';

class WarehouseModel extends Equatable {
  const WarehouseModel({
    required this.id,
    required this.dealerId,
    required this.name,
    required this.address,
    this.lat,
    this.lng,
    this.leafRegionId,
    this.freeDeliveryThreshold,
  });

  final int id;
  final int dealerId;
  final String name;
  final String address;
  final String? lat;
  final String? lng;
  final int? leafRegionId;
  final String? freeDeliveryThreshold;

  @override
  List<Object?> get props =>
      [id, dealerId, name, address, lat, lng, leafRegionId, freeDeliveryThreshold];

  factory WarehouseModel.fromJson(Map<String, dynamic> json) {
    return WarehouseModel(
      id: json['id'] as int,
      dealerId: json['dealer_id'] as int,
      name: json['name'] as String,
      address: json['address'] as String,
      lat: json['lat'] as String?,
      lng: json['lng'] as String?,
      leafRegionId: json['leaf_region_id'] as int?,
      freeDeliveryThreshold: json['free_delivery_threshold']?.toString(),
    );
  }
}
