import 'package:dartz/dartz.dart';
import '../entities/category.dart';

/// Abstract repository for category operations
abstract class CategoryRepository {
  Future<Either<String, List<Category>>> getAllCategories();
  Future<Either<String, Category>> getCategoryById(String id);
  Future<Either<String, void>> addCategory(Category category);
  Future<Either<String, void>> updateCategory(Category category);
  Future<Either<String, void>> deleteCategory(String id);
  Future<Either<String, void>> initializeDefaultCategories();
}
