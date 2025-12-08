import 'package:dartz/dartz.dart';
import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

/// Use case to get expenses by date range
class GetExpensesByDateRange {
  final ExpenseRepository _repository;

  GetExpensesByDateRange(this._repository);

  Future<Either<String, List<Expense>>> call(DateTime start, DateTime end) {
    return _repository.getExpensesByDateRange(start, end);
  }
}
