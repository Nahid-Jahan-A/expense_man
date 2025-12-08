import 'package:equatable/equatable.dart';
import '../../domain/entities/category.dart';

/// Base class for category states
abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class CategoryInitial extends CategoryState {
  const CategoryInitial();
}

/// Loading state
class CategoryLoading extends CategoryState {
  const CategoryLoading();
}

/// Loaded state with categories data
class CategoryLoaded extends CategoryState {
  final List<Category> categories;
  final String? selectedCategoryId;

  const CategoryLoaded({
    required this.categories,
    this.selectedCategoryId,
  });

  /// Get default categories
  List<Category> get defaultCategories =>
      categories.where((c) => c.isDefault).toList();

  /// Get custom categories
  List<Category> get customCategories =>
      categories.where((c) => !c.isDefault).toList();

  /// Get category by ID
  Category? getCategoryById(String id) {
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get selected category
  Category? get selectedCategory {
    if (selectedCategoryId == null) return null;
    return getCategoryById(selectedCategoryId!);
  }

  CategoryLoaded copyWith({
    List<Category>? categories,
    String? selectedCategoryId,
    bool clearSelectedCategory = false,
  }) {
    return CategoryLoaded(
      categories: categories ?? this.categories,
      selectedCategoryId: clearSelectedCategory
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
    );
  }

  @override
  List<Object?> get props => [categories, selectedCategoryId];
}

/// Error state
class CategoryError extends CategoryState {
  final String message;

  const CategoryError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State for category operation success
class CategoryOperationSuccess extends CategoryState {
  final String message;
  final CategoryLoaded previousState;

  const CategoryOperationSuccess({
    required this.message,
    required this.previousState,
  });

  @override
  List<Object?> get props => [message, previousState];
}
