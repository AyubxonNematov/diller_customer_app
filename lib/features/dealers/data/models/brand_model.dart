import 'package:equatable/equatable.dart';

class BrandModel extends Equatable {
  const BrandModel({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  @override
  List<Object?> get props => [id, name];

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['id'] as int,
      name: _parseName(json['name']),
    );
  }

  static String _parseName(dynamic value) {
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
