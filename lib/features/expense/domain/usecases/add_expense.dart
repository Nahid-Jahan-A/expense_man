import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

/// Use case to add a new expense
class AddExpense {
  final ExpenseRepository _repository;

  AddExpense(this._repository);

  Future<Either<Failure, void>> call(Expense expense) {
    return _repository.addExpense(expense);
  }
}
