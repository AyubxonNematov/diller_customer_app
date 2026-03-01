import 'package:equatable/equatable.dart';

class DealerModel extends Equatable {
  const DealerModel({
    required this.id,
    required this.name,
    this.phone,
    this.logo,
    this.address,
    this.description,
    this.categoryId,
  });

  final int id;
  final String name;
  final String? phone;
  final String? logo;
  final String? address;
  final String? description;
  final int? categoryId;

  @override
  List<Object?> get props => [id, name, phone, logo, address, description, categoryId];

  factory DealerModel.fromJson(Map<String, dynamic> json) {
    return DealerModel(
      id: json['id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      logo: json['logo'] as String?,
      address: json['address'] as String?,
      description: json['description'] as String?,
      categoryId: json['category_id'] as int?,
    );
  }
}
