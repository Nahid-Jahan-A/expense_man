import 'package:dartz/dartz.dart';
import '../repositories/category_repository.dart';

/// Use case to delete a category
class DeleteCategory {
  final CategoryRepository _repository;

  DeleteCategory(this._repository);

  Future<Either<String, void>> call(String id) {
    return _repository.deleteCategory(id);
  }
}
