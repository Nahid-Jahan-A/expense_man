import 'package:dartz/dartz.dart';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

/// Use case to add a new category
class AddCategory {
  final CategoryRepository _repository;

  AddCategory(this._repository);

  Future<Either<String, void>> call(Category category) {
    return _repository.addCategory(category);
  }
}
