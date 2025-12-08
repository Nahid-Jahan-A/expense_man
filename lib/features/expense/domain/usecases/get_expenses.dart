import 'package:dartz/dartz.dart';
import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

/// Use case to get all expenses
class GetExpenses {
  final ExpenseRepository _repository;

  GetExpenses(this._repository);

  Future<Either<String, List<Expense>>> call() {
    return _repository.getAllExpenses();
  }
}
