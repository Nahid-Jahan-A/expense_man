import 'package:hive/hive.dart';
import '../../domain/entities/category.dart';

part 'category_model.g.dart';

@HiveType(typeId: 1)
class CategoryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String nameEn;

  @HiveField(2)
  final String nameBn;

  @HiveField(3)
  final int color;

  @HiveField(4)
  final String icon;

  @HiveField(5)
  final bool isDefault;

  @HiveField(6)
  final int order;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime? updatedAt;

  CategoryModel({
    required this.id,
    required this.nameEn,
    required this.nameBn,
    required this.color,
    required this.icon,
    this.isDefault = false,
    this.order = 0,
    required this.createdAt,
    this.updatedAt,
  });

  /// Convert from entity
  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
      id: category.id,
      nameEn: category.nameEn,
      nameBn: category.nameBn,
      color: category.color,
      icon: category.icon,
      isDefault: category.isDefault,
      order: category.order,
      createdAt: category.createdAt,
      updatedAt: category.updatedAt,
    );
  }

  /// Convert to entity
  Category toEntity() {
    return Category(
      id: id,
      nameEn: nameEn,
      nameBn: nameBn,
      color: color,
      icon: icon,
      isDefault: isDefault,
      order: order,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Convert from JSON
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      nameEn: json['nameEn'] as String,
      nameBn: json['nameBn'] as String,
      color: json['color'] as int,
      icon: json['icon'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
      order: json['order'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameEn': nameEn,
      'nameBn': nameBn,
      'color': color,
      'icon': icon,
      'isDefault': isDefault,
      'order': order,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  CategoryModel copyWith({
    String? id,
    String? nameEn,
    String? nameBn,
    int? color,
    String? icon,
    bool? isDefault,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      nameEn: nameEn ?? this.nameEn,
      nameBn: nameBn ?? this.nameBn,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isDefault: isDefault ?? this.isDefault,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
