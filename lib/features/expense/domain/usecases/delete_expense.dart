import 'package:dartz/dartz.dart';
import '../repositories/expense_repository.dart';

/// Use case to delete an expense
class DeleteExpense {
  final ExpenseRepository _repository;

  DeleteExpense(this._repository);

  Future<Either<String, void>> call(String id) {
    return _repository.deleteExpense(id);
  }
}
