import 'package:equatable/equatable.dart';

/// Category entity representing an expense category
class Category extends Equatable {
  final String id;
  final String nameEn;
  final String nameBn;
  final int color;
  final String icon;
  final bool isDefault;
  final int order;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Category({
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

  /// Get localized name
  String getName(String locale) => locale == 'bn' ? nameBn : nameEn;

  /// Create a copy with updated values
  Category copyWith({
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
    return Category(
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

  @override
  List<Object?> get props => [
        id,
        nameEn,
        nameBn,
        color,
        icon,
        isDefault,
        order,
        createdAt,
        updatedAt,
      ];
}
