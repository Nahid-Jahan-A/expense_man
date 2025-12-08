import 'package:equatable/equatable.dart';

/// Expense entity representing a single expense record
class Expense extends Equatable {
  final String id;
  final double amount;
  final String categoryId;
  final String? note;
  final DateTime dateTime;
  final String paymentMethod;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Expense({
    required this.id,
    required this.amount,
    required this.categoryId,
    this.note,
    required this.dateTime,
    required this.paymentMethod,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create a copy with updated values
  Expense copyWith({
    String? id,
    double? amount,
    String? categoryId,
    String? note,
    DateTime? dateTime,
    String? paymentMethod,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
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

  @override
  List<Object?> get props => [
        id,
        amount,
        categoryId,
        note,
        dateTime,
        paymentMethod,
        createdAt,
        updatedAt,
      ];
}

/// Monthly expense summary
class MonthlySummary extends Equatable {
  final DateTime month;
  final double totalAmount;
  final int transactionCount;
  final Map<String, double> categoryBreakdown;
  final Map<String, double> paymentMethodBreakdown;
  final double averageExpense;
  final double highestExpense;
  final double lowestExpense;

  const MonthlySummary({
    required this.month,
    required this.totalAmount,
    required this.transactionCount,
    required this.categoryBreakdown,
    required this.paymentMethodBreakdown,
    required this.averageExpense,
    required this.highestExpense,
    required this.lowestExpense,
  });

  @override
  List<Object?> get props => [
        month,
        totalAmount,
        transactionCount,
        categoryBreakdown,
        paymentMethodBreakdown,
        averageExpense,
        highestExpense,
        lowestExpense,
      ];
}

/// Daily expense summary for charts
class DailySummary extends Equatable {
  final DateTime date;
  final double totalAmount;
  final int transactionCount;

  const DailySummary({
    required this.date,
    required this.totalAmount,
    required this.transactionCount,
  });

  @override
  List<Object?> get props => [date, totalAmount, transactionCount];
}
