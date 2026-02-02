import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

/// Use case to get monthly summary
class GetMonthlySummary {
  final ExpenseRepository _repository;

  GetMonthlySummary(this._repository);

  Future<Either<Failure, MonthlySummary>> call(int year, int month) {
    return _repository.getMonthlySummary(year, month);
  }
}
