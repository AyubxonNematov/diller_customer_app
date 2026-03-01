import 'package:equatable/equatable.dart';

class RegionModel extends Equatable {
  const RegionModel({
    required this.id,
    required this.name,
    this.parentId,
    this.hasChildren = false,
  });

  final int id;
  final String name;
  final int? parentId;
  final bool hasChildren;

  @override
  List<Object?> get props => [id, name, parentId, hasChildren];

  factory RegionModel.fromJson(Map<String, dynamic> json) {
    return RegionModel(
      id: json['id'] as int,
      name: json['name'] as String,
      parentId: json['parent_id'] as int?,
      hasChildren: json['has_children'] as bool? ?? false,
    );
  }
}
