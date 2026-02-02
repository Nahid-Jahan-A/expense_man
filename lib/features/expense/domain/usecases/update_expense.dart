import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

/// Use case to update an expense
class UpdateExpense {
  final ExpenseRepository _repository;

  UpdateExpense(this._repository);

  Future<Either<Failure, void>> call(Expense expense) {
    return _repository.updateExpense(expense);
  }
}
