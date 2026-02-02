import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_datasource.dart';
import '../models/category_model.dart';

/// Implementation of category repository
class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource _localDataSource;

  CategoryRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, List<Category>>> getAllCategories() async {
    try {
      final models = await _localDataSource.getAllCategories();
      final categories = models.map((m) => m.toEntity()).toList();
      return Right(categories);
    } catch (e) {
      return Left(CacheFailure.read(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Category>> getCategoryById(String id) async {
    try {
      final model = await _localDataSource.getCategoryById(id);
      if (model == null) {
        return Left(CacheFailure.notFound('Category with id: $id'));
      }
      return Right(model.toEntity());
    } catch (e) {
      return Left(CacheFailure.read(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addCategory(Category category) async {
    try {
      final model = CategoryModel.fromEntity(category);
      await _localDataSource.addCategory(model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure.write(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateCategory(Category category) async {
    try {
      final model = CategoryModel.fromEntity(category);
      await _localDataSource.updateCategory(model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure.write(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) async {
    try {
      await _localDataSource.deleteCategory(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure.delete(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> initializeDefaultCategories() async {
    try {
      await _localDataSource.initializeDefaultCategories();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure.write(e.toString()));
    }
  }
}
