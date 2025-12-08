import 'package:dartz/dartz.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_local_datasource.dart';
import '../models/expense_model.dart';

/// Implementation of expense repository
class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource _localDataSource;

  ExpenseRepositoryImpl(this._localDataSource);

  @override
  Future<Either<String, List<Expense>>> getAllExpenses() async {
    try {
      final models = await _localDataSource.getAllExpenses();
      final expenses = models.map((m) => m.toEntity()).toList();
      return Right(expenses);
    } catch (e) {
      return Left('Failed to get expenses: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, Expense>> getExpenseById(String id) async {
    try {
      final model = await _localDataSource.getExpenseById(id);
      if (model == null) {
        return const Left('Expense not found');
      }
      return Right(model.toEntity());
    } catch (e) {
      return Left('Failed to get expense: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<Expense>>> getExpensesByDateRange(
      DateTime start, DateTime end) async {
    try {
      final models = await _localDataSource.getExpensesByDateRange(start, end);
      final expenses = models.map((m) => m.toEntity()).toList();
      return Right(expenses);
    } catch (e) {
      return Left('Failed to get expenses: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<Expense>>> getExpensesByCategory(
      String categoryId) async {
    try {
      final models = await _localDataSource.getExpensesByCategory(categoryId);
      final expenses = models.map((m) => m.toEntity()).toList();
      return Right(expenses);
    } catch (e) {
      return Left('Failed to get expenses: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<Expense>>> getExpensesByMonth(
      int year, int month) async {
    try {
      final models = await _localDataSource.getExpensesByMonth(year, month);
      final expenses = models.map((m) => m.toEntity()).toList();
      return Right(expenses);
    } catch (e) {
      return Left('Failed to get expenses: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, MonthlySummary>> getMonthlySummary(
      int year, int month) async {
    try {
      final models = await _localDataSource.getExpensesByMonth(year, month);
      final expenses = models.map((m) => m.toEntity()).toList();

      if (expenses.isEmpty) {
        return Right(MonthlySummary(
          month: DateTime(year, month),
          totalAmount: 0,
          transactionCount: 0,
          categoryBreakdown: {},
          paymentMethodBreakdown: {},
          averageExpense: 0,
          highestExpense: 0,
          lowestExpense: 0,
        ));
      }

      // Calculate category breakdown
      final categoryBreakdown = <String, double>{};
      for (final expense in expenses) {
        categoryBreakdown[expense.categoryId] =
            (categoryBreakdown[expense.categoryId] ?? 0) + expense.amount;
      }

      // Calculate payment method breakdown
      final paymentMethodBreakdown = <String, double>{};
      for (final expense in expenses) {
        paymentMethodBreakdown[expense.paymentMethod] =
            (paymentMethodBreakdown[expense.paymentMethod] ?? 0) + expense.amount;
      }

      final totalAmount = expenses.fold<double>(
        0,
        (sum, expense) => sum + expense.amount,
      );

      final amounts = expenses.map((e) => e.amount).toList();

      return Right(MonthlySummary(
        month: DateTime(year, month),
        totalAmount: totalAmount,
        transactionCount: expenses.length,
        categoryBreakdown: categoryBreakdown,
        paymentMethodBreakdown: paymentMethodBreakdown,
        averageExpense: totalAmount / expenses.length,
        highestExpense: amounts.reduce((a, b) => a > b ? a : b),
        lowestExpense: amounts.reduce((a, b) => a < b ? a : b),
      ));
    } catch (e) {
      return Left('Failed to get monthly summary: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> addExpense(Expense expense) async {
    try {
      final model = ExpenseModel.fromEntity(expense);
      await _localDataSource.addExpense(model);
      return const Right(null);
    } catch (e) {
      return Left('Failed to add expense: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> updateExpense(Expense expense) async {
    try {
      final model = ExpenseModel.fromEntity(expense);
      await _localDataSource.updateExpense(model);
      return const Right(null);
    } catch (e) {
      return Left('Failed to update expense: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> deleteExpense(String id) async {
    try {
      await _localDataSource.deleteExpense(id);
      return const Right(null);
    } catch (e) {
      return Left('Failed to delete expense: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> deleteAllExpenses() async {
    try {
      await _localDataSource.deleteAllExpenses();
      return const Right(null);
    } catch (e) {
      return Left('Failed to delete all expenses: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<Expense>>> searchExpenses(String query) async {
    try {
      final models = await _localDataSource.searchExpenses(query);
      final expenses = models.map((m) => m.toEntity()).toList();
      return Right(expenses);
    } catch (e) {
      return Left('Failed to search expenses: ${e.toString()}');
    }
  }
}
