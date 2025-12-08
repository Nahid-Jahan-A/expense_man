import 'package:dartz/dartz.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_datasource.dart';
import '../models/category_model.dart';

/// Implementation of category repository
class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource _localDataSource;

  CategoryRepositoryImpl(this._localDataSource);

  @override
  Future<Either<String, List<Category>>> getAllCategories() async {
    try {
      final models = await _localDataSource.getAllCategories();
      final categories = models.map((m) => m.toEntity()).toList();
      return Right(categories);
    } catch (e) {
      return Left('Failed to get categories: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, Category>> getCategoryById(String id) async {
    try {
      final model = await _localDataSource.getCategoryById(id);
      if (model == null) {
        return const Left('Category not found');
      }
      return Right(model.toEntity());
    } catch (e) {
      return Left('Failed to get category: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> addCategory(Category category) async {
    try {
      final model = CategoryModel.fromEntity(category);
      await _localDataSource.addCategory(model);
      return const Right(null);
    } catch (e) {
      return Left('Failed to add category: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> updateCategory(Category category) async {
    try {
      final model = CategoryModel.fromEntity(category);
      await _localDataSource.updateCategory(model);
      return const Right(null);
    } catch (e) {
      return Left('Failed to update category: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> deleteCategory(String id) async {
    try {
      await _localDataSource.deleteCategory(id);
      return const Right(null);
    } catch (e) {
      return Left('Failed to delete category: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> initializeDefaultCategories() async {
    try {
      await _localDataSource.initializeDefaultCategories();
      return const Right(null);
    } catch (e) {
      return Left('Failed to initialize categories: ${e.toString()}');
    }
  }
}
