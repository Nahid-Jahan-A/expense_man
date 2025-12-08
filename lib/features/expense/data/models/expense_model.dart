import 'package:hive/hive.dart';
import '../../domain/entities/expense.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 0)
class ExpenseModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String categoryId;

  @HiveField(3)
  final String? note;

  @HiveField(4)
  final DateTime dateTime;

  @HiveField(5)
  final String paymentMethod;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime? updatedAt;

  ExpenseModel({
    required this.id,
    required this.amount,
    required this.categoryId,
    this.note,
    required this.dateTime,
    required this.paymentMethod,
    required this.createdAt,
    this.updatedAt,
  });

  /// Convert from entity
  factory ExpenseModel.fromEntity(Expense expense) {
    return ExpenseModel(
      id: expense.id,
      amount: expense.amount,
      categoryId: expense.categoryId,
      note: expense.note,
      dateTime: expense.dateTime,
      paymentMethod: expense.paymentMethod,
      createdAt: expense.createdAt,
      updatedAt: expense.updatedAt,
    );
  }

  /// Convert to entity
  Expense toEntity() {
    return Expense(
      id: id,
      amount: amount,
      categoryId: categoryId,
      note: note,
      dateTime: dateTime,
      paymentMethod: paymentMethod,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Convert from JSON
  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['categoryId'] as String,
      note: json['note'] as String?,
      dateTime: DateTime.parse(json['dateTime'] as String),
      paymentMethod: json['paymentMethod'] as String,
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
      'amount': amount,
      'categoryId': categoryId,
      'note': note,
      'dateTime': dateTime.toIso8601String(),
      'paymentMethod': paymentMethod,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  ExpenseModel copyWith({
    String? id,
    double? amount,
    String? categoryId,
    String? note,
    DateTime? dateTime,
    String? paymentMethod,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      dateTime: dateTime ?? this.dateTime,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
