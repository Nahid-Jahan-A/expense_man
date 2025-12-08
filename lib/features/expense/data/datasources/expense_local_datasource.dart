import 'package:hive/hive.dart';
import '../models/expense_model.dart';

/// Abstract class for expense local data source
abstract class ExpenseLocalDataSource {
  Future<List<ExpenseModel>> getAllExpenses();
  Future<ExpenseModel?> getExpenseById(String id);
  Future<List<ExpenseModel>> getExpensesByDateRange(DateTime start, DateTime end);
  Future<List<ExpenseModel>> getExpensesByCategory(String categoryId);
  Future<List<ExpenseModel>> getExpensesByMonth(int year, int month);
  Future<void> addExpense(ExpenseModel expense);
  Future<void> updateExpense(ExpenseModel expense);
  Future<void> deleteExpense(String id);
  Future<void> deleteAllExpenses();
  Future<List<ExpenseModel>> searchExpenses(String query);
}

/// Implementation of expense local data source using Hive
class ExpenseLocalDataSourceImpl implements ExpenseLocalDataSource {
  final Box _box;

  ExpenseLocalDataSourceImpl(this._box);

  @override
  Future<List<ExpenseModel>> getAllExpenses() async {
    try {
      final expenses = _box.values
          .map((e) => _mapToExpenseModel(e))
          .whereType<ExpenseModel>()
          .toList();

      // Sort by date descending
      expenses.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      return expenses;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<ExpenseModel?> getExpenseById(String id) async {
    try {
      final data = _box.get(id);
      return data != null ? _mapToExpenseModel(data) : null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<ExpenseModel>> getExpensesByDateRange(DateTime start, DateTime end) async {
    try {
      final expenses = _box.values
          .map((e) => _mapToExpenseModel(e))
          .whereType<ExpenseModel>()
          .where((e) =>
              e.dateTime.isAfter(start.subtract(const Duration(days: 1))) &&
              e.dateTime.isBefore(end.add(const Duration(days: 1))))
          .toList();

      expenses.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      return expenses;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<ExpenseModel>> getExpensesByCategory(String categoryId) async {
    try {
      final expenses = _box.values
          .map((e) => _mapToExpenseModel(e))
          .whereType<ExpenseModel>()
          .where((e) => e.categoryId == categoryId)
          .toList();

      expenses.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      return expenses;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<ExpenseModel>> getExpensesByMonth(int year, int month) async {
    try {
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0, 23, 59, 59);
      return getExpensesByDateRange(startDate, endDate);
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> addExpense(ExpenseModel expense) async {
    await _box.put(expense.id, expense.toJson());
  }

  @override
  Future<void> updateExpense(ExpenseModel expense) async {
    await _box.put(expense.id, expense.toJson());
  }

  @override
  Future<void> deleteExpense(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> deleteAllExpenses() async {
    await _box.clear();
  }

  @override
  Future<List<ExpenseModel>> searchExpenses(String query) async {
    try {
      final lowerQuery = query.toLowerCase();
      final expenses = _box.values
          .map((e) => _mapToExpenseModel(e))
          .whereType<ExpenseModel>()
          .where((e) =>
              (e.note?.toLowerCase().contains(lowerQuery) ?? false) ||
              e.amount.toString().contains(query))
          .toList();

      expenses.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      return expenses;
    } catch (e) {
      return [];
    }
  }

  ExpenseModel? _mapToExpenseModel(dynamic data) {
    try {
      if (data is Map) {
        return ExpenseModel.fromJson(Map<String, dynamic>.from(data));
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
