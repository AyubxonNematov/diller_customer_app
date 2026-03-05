import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  const ProductModel({
    required this.id,
    required this.warehouseId,
    this.brandId,
    this.unitId,
    required this.name,
    required this.price,
    this.earningsPerUnit,
    this.images = const [],
    this.description,
    this.brandName,
    this.unitName,
  });

  final int id;
  final int warehouseId;
  final int? brandId;
  final int? unitId;
  final String name;
  final String price;
  final String? earningsPerUnit;
  final List<String> images;
  final String? description;
  final String? brandName;
  final String? unitName;

  String? get firstImage => images.isNotEmpty ? images.first : null;

  @override
  List<Object?> get props => [
        id,
        warehouseId,
        brandId,
        unitId,
        name,
        price,
        earningsPerUnit,
        images,
        description,
        brandName,
        unitName,
      ];

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'];
    List<String> imgList = [];
    if (rawImages is List) {
      imgList = rawImages
          .map((e) => e?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return ProductModel(
      id: json['id'] as int,
      warehouseId: json['warehouse_id'] as int,
      brandId: json['brand_id'] as int?,
      unitId: json['unit_id'] as int?,
      name: _parseTranslatable(json['name']),
      price: (json['price'] ?? 0).toString(),
      earningsPerUnit: json['earnings_per_unit']?.toString(),
      images: imgList,
      description: _parseTranslatable(json['description']),
      brandName: _parseTranslatable(json['brand_name']),
      unitName: _parseTranslatable(json['unit_name']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'warehouse_id': warehouseId,
      'brand_id': brandId,
      'unit_id': unitId,
      'name': name,
      'price': price,
      'earnings_per_unit': earningsPerUnit,
      'images': images,
      'description': description,
      'brand_name': brandName,
      'unit_name': unitName,
    };
  }

  static String _parseTranslatable(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is Map) {
      return (value['uz'] ?? value['ru'] ?? value['en'] ?? value.values.first)
              ?.toString() ??
          '';
    }
    return value.toString();
  }
}
