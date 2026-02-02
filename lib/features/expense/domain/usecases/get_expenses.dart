import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

/// Use case to get all expenses
class GetExpenses {
  final ExpenseRepository _repository;

  GetExpenses(this._repository);

  Future<Either<Failure, List<Expense>>> call() {
    return _repository.getAllExpenses();
  }
}
