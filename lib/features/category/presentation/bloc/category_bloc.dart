import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/usecases/add_category.dart';
import '../../domain/usecases/delete_category.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/update_category.dart';
import 'category_event.dart';
import 'category_state.dart';

/// BLoC for category management
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetCategories getCategories;
  final AddCategory addCategory;
  final UpdateCategory updateCategory;
  final DeleteCategory deleteCategory;

  CategoryBloc({
    required this.getCategories,
    required this.addCategory,
    required this.updateCategory,
    required this.deleteCategory,
  }) : super(const CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<AddCategoryEvent>(_onAddCategory);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
    on<SelectCategory>(_onSelectCategory);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryLoading());

    final result = await getCategories();
    result.fold(
      (failure) => emit(CategoryError(failure)),
      (categories) => emit(CategoryLoaded(categories: categories)),
    );
  }

  Future<void> _onAddCategory(
    AddCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    final currentState = state;

    final result = await addCategory(event.category);

    if (result.isLeft()) {
      emit(CategoryError(result.fold((l) => l, (_) => CacheFailure.write())));
      return;
    }

    final categoriesResult = await getCategories();
    categoriesResult.fold(
      (failure) => emit(CategoryError(failure)),
      (categories) {
        if (currentState is CategoryLoaded) {
          emit(CategoryOperationSuccess(
            message: 'Category added successfully',
            previousState: currentState.copyWith(categories: categories),
          ));
          emit(currentState.copyWith(categories: categories));
        } else {
          emit(CategoryLoaded(categories: categories));
        }
      },
    );
  }

  Future<void> _onUpdateCategory(
    UpdateCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    final currentState = state;

    final result = await updateCategory(event.category);

    if (result.isLeft()) {
      emit(CategoryError(result.fold((l) => l, (_) => CacheFailure.write())));
      return;
    }

    final categoriesResult = await getCategories();
    categoriesResult.fold(
      (failure) => emit(CategoryError(failure)),
      (categories) {
        if (currentState is CategoryLoaded) {
          emit(CategoryOperationSuccess(
            message: 'Category updated successfully',
            previousState: currentState.copyWith(categories: categories),
          ));
          emit(currentState.copyWith(categories: categories));
        } else {
          emit(CategoryLoaded(categories: categories));
        }
      },
    );
  }

  Future<void> _onDeleteCategory(
    DeleteCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    final currentState = state;

    final result = await deleteCategory(event.id);

    if (result.isLeft()) {
      emit(CategoryError(result.fold((l) => l, (_) => CacheFailure.delete())));
      return;
    }

    final categoriesResult = await getCategories();
    categoriesResult.fold(
      (failure) => emit(CategoryError(failure)),
      (categories) {
        if (currentState is CategoryLoaded) {
          emit(CategoryOperationSuccess(
            message: 'Category deleted successfully',
            previousState: currentState.copyWith(categories: categories),
          ));
          emit(currentState.copyWith(
            categories: categories,
            clearSelectedCategory: currentState.selectedCategoryId == event.id,
          ));
        } else {
          emit(CategoryLoaded(categories: categories));
        }
      },
    );
  }

  void _onSelectCategory(
    SelectCategory event,
    Emitter<CategoryState> emit,
  ) {
    final currentState = state;

    if (currentState is CategoryLoaded) {
      emit(currentState.copyWith(
        selectedCategoryId: event.categoryId,
        clearSelectedCategory: event.categoryId == null,
      ));
    }
  }
}
