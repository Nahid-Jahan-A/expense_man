import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_manager/features/category/domain/entities/category.dart';
import 'package:expense_manager/features/category/domain/usecases/add_category.dart';
import 'package:expense_manager/features/category/domain/usecases/delete_category.dart';
import 'package:expense_manager/features/category/domain/usecases/get_categories.dart';
import 'package:expense_manager/features/category/domain/usecases/update_category.dart';
import 'package:expense_manager/features/category/presentation/bloc/category_bloc.dart';
import 'package:expense_manager/features/category/presentation/bloc/category_event.dart';
import 'package:expense_manager/features/category/presentation/bloc/category_state.dart';

// Mock classes
class MockGetCategories extends Mock implements GetCategories {}

class MockAddCategory extends Mock implements AddCategory {}

class MockUpdateCategory extends Mock implements UpdateCategory {}

class MockDeleteCategory extends Mock implements DeleteCategory {}

void main() {
  late CategoryBloc categoryBloc;
  late MockGetCategories mockGetCategories;
  late MockAddCategory mockAddCategory;
  late MockUpdateCategory mockUpdateCategory;
  late MockDeleteCategory mockDeleteCategory;

  setUp(() {
    mockGetCategories = MockGetCategories();
    mockAddCategory = MockAddCategory();
    mockUpdateCategory = MockUpdateCategory();
    mockDeleteCategory = MockDeleteCategory();

    categoryBloc = CategoryBloc(
      getCategories: mockGetCategories,
      addCategory: mockAddCategory,
      updateCategory: mockUpdateCategory,
      deleteCategory: mockDeleteCategory,
    );
  });

  tearDown(() {
    categoryBloc.close();
  });

  // Test data
  final testCategory = Category(
    id: 'food',
    nameEn: 'Food',
    nameBn: 'খাবার',
    color: 0xFFE91E63,
    icon: 'restaurant',
    isDefault: true,
    order: 0,
    createdAt: DateTime.now(),
  );

  final testCategories = [testCategory];

  group('LoadCategories', () {
    blocTest<CategoryBloc, CategoryState>(
      'emits [CategoryLoading, CategoryLoaded] when LoadCategories succeeds',
      build: () {
        when(() => mockGetCategories())
            .thenAnswer((_) async => Right(testCategories));
        return categoryBloc;
      },
      act: (bloc) => bloc.add(const LoadCategories()),
      expect: () => [
        const CategoryLoading(),
        CategoryLoaded(categories: testCategories),
      ],
      verify: (_) {
        verify(() => mockGetCategories()).called(1);
      },
    );

    blocTest<CategoryBloc, CategoryState>(
      'emits [CategoryLoading, CategoryError] when LoadCategories fails',
      build: () {
        when(() => mockGetCategories())
            .thenAnswer((_) async => const Left('Failed to load categories'));
        return categoryBloc;
      },
      act: (bloc) => bloc.add(const LoadCategories()),
      expect: () => [
        const CategoryLoading(),
        const CategoryError('Failed to load categories'),
      ],
    );
  });

  group('SelectCategory', () {
    blocTest<CategoryBloc, CategoryState>(
      'updates selectedCategoryId when SelectCategory is added',
      build: () => categoryBloc,
      seed: () => CategoryLoaded(categories: testCategories),
      act: (bloc) => bloc.add(const SelectCategory('food')),
      expect: () => [
        isA<CategoryLoaded>().having(
          (state) => state.selectedCategoryId,
          'selectedCategoryId',
          'food',
        ),
      ],
    );

    blocTest<CategoryBloc, CategoryState>(
      'clears selectedCategoryId when SelectCategory is added with null',
      build: () => categoryBloc,
      seed: () => CategoryLoaded(
        categories: testCategories,
        selectedCategoryId: 'food',
      ),
      act: (bloc) => bloc.add(const SelectCategory(null)),
      expect: () => [
        isA<CategoryLoaded>().having(
          (state) => state.selectedCategoryId,
          'selectedCategoryId',
          isNull,
        ),
      ],
    );
  });

  group('CategoryLoaded helpers', () {
    test('defaultCategories returns only default categories', () {
      final customCategory = Category(
        id: 'custom',
        nameEn: 'Custom',
        nameBn: 'কাস্টম',
        color: 0xFF000000,
        icon: 'category',
        isDefault: false,
        order: 1,
        createdAt: DateTime.now(),
      );

      final state = CategoryLoaded(
        categories: [testCategory, customCategory],
      );

      expect(state.defaultCategories, [testCategory]);
      expect(state.customCategories, [customCategory]);
    });

    test('getCategoryById returns correct category', () {
      final state = CategoryLoaded(categories: testCategories);

      expect(state.getCategoryById('food'), testCategory);
      expect(state.getCategoryById('unknown'), isNull);
    });
  });
}
