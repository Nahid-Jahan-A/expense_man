import 'package:dartz/dartz.dart';
import '../entities/expense.dart';

/// Abstract repository for expense operations
abstract class ExpenseRepository {
  Future<Either<String, List<Expense>>> getAllExpenses();
  Future<Either<String, Expense>> getExpenseById(String id);
  Future<Either<String, List<Expense>>> getExpensesByDateRange(DateTime start, DateTime end);
  Future<Either<String, List<Expense>>> getExpensesByCategory(String categoryId);
  Future<Either<String, List<Expense>>> getExpensesByMonth(int year, int month);
  Future<Either<String, MonthlySummary>> getMonthlySummary(int year, int month);
  Future<Either<String, void>> addExpense(Expense expense);
  Future<Either<String, void>> updateExpense(Expense expense);
  Future<Either<String, void>> deleteExpense(String id);
  Future<Either<String, void>> deleteAllExpenses();
  Future<Either<String, List<Expense>>> searchExpenses(String query);
}
