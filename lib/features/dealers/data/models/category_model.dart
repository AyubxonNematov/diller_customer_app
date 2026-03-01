import 'package:equatable/equatable.dart';

class CategoryModel extends Equatable {
  const CategoryModel({
    required this.id,
    required this.name,
    this.icon,
    this.parentId,
    this.hasChildren = false,
  });

  final int id;
  final String name;
  final String? icon;
  final int? parentId;
  final bool hasChildren;

  @override
  List<Object?> get props => [id, name, icon, parentId, hasChildren];

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      parentId: json['parent_id'] as int?,
      hasChildren: json['has_children'] as bool? ?? false,
    );
  }
}
