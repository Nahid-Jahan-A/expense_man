import 'package:equatable/equatable.dart';
import '../../domain/entities/category.dart';

/// Base class for category events
abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all categories
class LoadCategories extends CategoryEvent {
  const LoadCategories();
}

/// Event to add a new category
class AddCategoryEvent extends CategoryEvent {
  final Category category;

  const AddCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

/// Event to update a category
class UpdateCategoryEvent extends CategoryEvent {
  final Category category;

  const UpdateCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

/// Event to delete a category
class DeleteCategoryEvent extends CategoryEvent {
  final String id;

  const DeleteCategoryEvent(this.id);

  @override
  List<Object?> get props => [id];
}

/// Event to select a category
class SelectCategory extends CategoryEvent {
  final String? categoryId;

  const SelectCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}
