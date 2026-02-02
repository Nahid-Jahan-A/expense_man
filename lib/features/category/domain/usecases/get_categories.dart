import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

/// Use case to get all categories
class GetCategories {
  final CategoryRepository _repository;

  GetCategories(this._repository);

  Future<Either<Failure, List<Category>>> call() {
    return _repository.getAllCategories();
  }
}
