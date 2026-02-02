import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/expense.dart';

/// Abstract repository for expense operations
abstract class ExpenseRepository {
  Future<Either<Failure, List<Expense>>> getAllExpenses();
  Future<Either<Failure, Expense>> getExpenseById(String id);
  Future<Either<Failure, List<Expense>>> getExpensesByDateRange(DateTime start, DateTime end);
  Future<Either<Failure, List<Expense>>> getExpensesByCategory(String categoryId);
  Future<Either<Failure, List<Expense>>> getExpensesByMonth(int year, int month);
  Future<Either<Failure, MonthlySummary>> getMonthlySummary(int year, int month);
  Future<Either<Failure, void>> addExpense(Expense expense);
  Future<Either<Failure, void>> updateExpense(Expense expense);
  Future<Either<Failure, void>> deleteExpense(String id);
  Future<Either<Failure, void>> deleteAllExpenses();
  Future<Either<Failure, List<Expense>>> searchExpenses(String query);
}
