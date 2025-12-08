import 'package:dartz/dartz.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

/// Use case to update a category
class UpdateCategory {
  final CategoryRepository _repository;

  UpdateCategory(this._repository);

  Future<Either<String, void>> call(Category category) {
    return _repository.updateCategory(category);
  }
}
