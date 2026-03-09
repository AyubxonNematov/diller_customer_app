import 'package:equatable/equatable.dart';
import 'package:sement_market_customer/features/dealers/data/models/warehouse_model.dart';
import 'package:sement_market_customer/features/orders/data/models/order_item_model.dart';

enum OrderStatus {
  new_('new', 'Yangi'),
  inProcess('in_process', 'Jarayonda'),
  completed('completed', 'Yakunlangan');

  const OrderStatus(this.value, this.label);
  final String value;
  final String label;

  static OrderStatus fromString(String? s) {
    return OrderStatus.values.firstWhere(
      (e) => e.value == s,
      orElse: () => OrderStatus.new_,
    );
  }
}

enum DeliveryType {
  pickup('pickup', 'Olib ketish'),
  delivery('delivery', 'Yetkazib berish'),
  freeDelivery('free_delivery', 'Bepul yetkazish');

  const DeliveryType(this.value, this.label);
  final String value;
  final String label;

  static DeliveryType fromString(String? s) {
    return DeliveryType.values.firstWhere(
      (e) => e.value == s,
      orElse: () => DeliveryType.pickup,
    );
  }
}

class OrderModel extends Equatable {
  const OrderModel({
    required this.id,
    required this.customerId,
    required this.warehouseId,
    required this.status,
    required this.deliveryType,
    this.totalPrice,
    this.totalEarnings,
    this.createdAt,
    this.updatedAt,
    this.warehouse,
    this.items = const [],
    this.customerLogisticOffer,
    this.logistic,
  });

  final int id;
  final int customerId;
  final int warehouseId;
  final OrderStatus status;
  final DeliveryType deliveryType;
  final String? totalPrice;
  final String? totalEarnings;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final WarehouseModel? warehouse;
  final List<OrderItemModel> items;
  final Map<String, dynamic>? customerLogisticOffer;
  final Map<String, dynamic>? logistic;

  @override
  List<Object?> get props => [
        id,
        customerId,
        warehouseId,
        status,
        deliveryType,
        totalPrice,
        totalEarnings,
        createdAt,
        updatedAt,
        warehouse,
        items,
      ];

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return OrderModel(
      id: json['id'] as int,
      customerId: json['customer_id'] as int,
      warehouseId: json['warehouse_id'] as int,
      status: OrderStatus.fromString(json['status']?.toString()),
      deliveryType: DeliveryType.fromString(json['delivery_type']?.toString()),
      totalPrice: json['total_price']?.toString(),
      totalEarnings: json['total_earnings']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      warehouse: json['warehouse'] != null
          ? WarehouseModel.fromJson(
              (json['warehouse'] as Map).cast<String, dynamic>())
          : null,
      items: rawItems
          .map((e) =>
              OrderItemModel.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      customerLogisticOffer: json['customer_logistic_offer'] != null
          ? (json['customer_logistic_offer'] as Map).cast<String, dynamic>()
          : null,
      logistic: json['logistic'] != null
          ? (json['logistic'] as Map).cast<String, dynamic>()
          : null,
    );
  }
}
