import 'package:hive/hive.dart';
import '../models/category_model.dart';
import '../../../../core/constants/enums.dart';

/// Abstract class for category local data source
abstract class CategoryLocalDataSource {
  Future<List<CategoryModel>> getAllCategories();
  Future<CategoryModel?> getCategoryById(String id);
  Future<void> addCategory(CategoryModel category);
  Future<void> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String id);
  Future<void> initializeDefaultCategories();
  Future<bool> hasCategories();
}

/// Implementation of category local data source using Hive
class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  final Box _box;

  CategoryLocalDataSourceImpl(this._box);

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      // Initialize default categories if empty
      if (_box.isEmpty) {
        await initializeDefaultCategories();
      }

      final categories = _box.values
          .map((e) => _mapToCategoryModel(e))
          .whereType<CategoryModel>()
          .toList();

      // Sort by order
      categories.sort((a, b) => a.order.compareTo(b.order));
      return categories;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<CategoryModel?> getCategoryById(String id) async {
    try {
      final data = _box.get(id);
      return data != null ? _mapToCategoryModel(data) : null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> addCategory(CategoryModel category) async {
    await _box.put(category.id, category.toJson());
  }

  @override
  Future<void> updateCategory(CategoryModel category) async {
    await _box.put(category.id, category.toJson());
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> initializeDefaultCategories() async {
    final defaultCategories = DefaultCategory.values;
    for (int i = 0; i < defaultCategories.length; i++) {
      final category = defaultCategories[i];
      final model = CategoryModel(
        id: category.id,
        nameEn: category.nameEn,
        nameBn: category.nameBn,
        color: category.color,
        icon: category.icon,
        isDefault: true,
        order: i,
        createdAt: DateTime.now(),
      );
      await _box.put(model.id, model.toJson());
    }
  }

  @override
  Future<bool> hasCategories() async {
    return _box.isNotEmpty;
  }

  CategoryModel? _mapToCategoryModel(dynamic data) {
    try {
      if (data is Map) {
        return CategoryModel.fromJson(Map<String, dynamic>.from(data));
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
