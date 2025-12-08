import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_manager/features/expense/domain/entities/expense.dart';
import 'package:expense_manager/features/expense/domain/usecases/add_expense.dart';
import 'package:expense_manager/features/expense/domain/usecases/delete_expense.dart';
import 'package:expense_manager/features/expense/domain/usecases/get_expenses.dart';
import 'package:expense_manager/features/expense/domain/usecases/get_expenses_by_date_range.dart';
import 'package:expense_manager/features/expense/domain/usecases/get_monthly_summary.dart';
import 'package:expense_manager/features/expense/domain/usecases/update_expense.dart';
import 'package:expense_manager/features/expense/presentation/bloc/expense_bloc.dart';
import 'package:expense_manager/features/expense/presentation/bloc/expense_event.dart';
import 'package:expense_manager/features/expense/presentation/bloc/expense_state.dart';

// Mock classes
class MockGetExpenses extends Mock implements GetExpenses {}

class MockGetExpensesByDateRange extends Mock implements GetExpensesByDateRange {}

class MockGetMonthlySummary extends Mock implements GetMonthlySummary {}

class MockAddExpense extends Mock implements AddExpense {}

class MockUpdateExpense extends Mock implements UpdateExpense {}

class MockDeleteExpense extends Mock implements DeleteExpense {}

void main() {
  late ExpenseBloc expenseBloc;
  late MockGetExpenses mockGetExpenses;
  late MockGetExpensesByDateRange mockGetExpensesByDateRange;
  late MockGetMonthlySummary mockGetMonthlySummary;
  late MockAddExpense mockAddExpense;
  late MockUpdateExpense mockUpdateExpense;
  late MockDeleteExpense mockDeleteExpense;

  setUp(() {
    mockGetExpenses = MockGetExpenses();
    mockGetExpensesByDateRange = MockGetExpensesByDateRange();
    mockGetMonthlySummary = MockGetMonthlySummary();
    mockAddExpense = MockAddExpense();
    mockUpdateExpense = MockUpdateExpense();
    mockDeleteExpense = MockDeleteExpense();

    expenseBloc = ExpenseBloc(
      getExpenses: mockGetExpenses,
      getExpensesByDateRange: mockGetExpensesByDateRange,
      getMonthlySummary: mockGetMonthlySummary,
      addExpense: mockAddExpense,
      updateExpense: mockUpdateExpense,
      deleteExpense: mockDeleteExpense,
    );
  });

  tearDown(() {
    expenseBloc.close();
  });

  // Test data
  final testExpense = Expense(
    id: '1',
    amount: 100.0,
    categoryId: 'food',
    note: 'Test expense',
    dateTime: DateTime.now(),
    paymentMethod: 'cash',
    createdAt: DateTime.now(),
  );

  final testExpenses = [testExpense];

  group('LoadExpenses', () {
    blocTest<ExpenseBloc, ExpenseState>(
      'emits [ExpenseLoading, ExpenseLoaded] when LoadExpenses succeeds',
      build: () {
        when(() => mockGetExpenses())
            .thenAnswer((_) async => Right(testExpenses));
        return expenseBloc;
      },
      act: (bloc) => bloc.add(const LoadExpenses()),
      expect: () => [
        const ExpenseLoading(),
        ExpenseLoaded(expenses: testExpenses),
      ],
      verify: (_) {
        verify(() => mockGetExpenses()).called(1);
      },
    );

    blocTest<ExpenseBloc, ExpenseState>(
      'emits [ExpenseLoading, ExpenseError] when LoadExpenses fails',
      build: () {
        when(() => mockGetExpenses())
            .thenAnswer((_) async => const Left('Failed to load expenses'));
        return expenseBloc;
      },
      act: (bloc) => bloc.add(const LoadExpenses()),
      expect: () => [
        const ExpenseLoading(),
        const ExpenseError('Failed to load expenses'),
      ],
    );
  });

  group('AddExpenseEvent', () {
    blocTest<ExpenseBloc, ExpenseState>(
      'emits success states when AddExpenseEvent succeeds',
      build: () {
        when(() => mockAddExpense(testExpense))
            .thenAnswer((_) async => const Right(null));
        when(() => mockGetExpenses())
            .thenAnswer((_) async => Right(testExpenses));
        return expenseBloc;
      },
      act: (bloc) => bloc.add(AddExpenseEvent(testExpense)),
      verify: (_) {
        verify(() => mockAddExpense(testExpense)).called(1);
        verify(() => mockGetExpenses()).called(1);
      },
    );

    blocTest<ExpenseBloc, ExpenseState>(
      'emits [ExpenseError] when AddExpenseEvent fails',
      build: () {
        when(() => mockAddExpense(testExpense))
            .thenAnswer((_) async => const Left('Failed to add expense'));
        return expenseBloc;
      },
      act: (bloc) => bloc.add(AddExpenseEvent(testExpense)),
      expect: () => [
        const ExpenseError('Failed to add expense'),
      ],
    );
  });

  group('DeleteExpenseEvent', () {
    blocTest<ExpenseBloc, ExpenseState>(
      'emits success states when DeleteExpenseEvent succeeds',
      build: () {
        when(() => mockDeleteExpense('1'))
            .thenAnswer((_) async => const Right(null));
        when(() => mockGetExpenses())
            .thenAnswer((_) async => const Right([]));
        return expenseBloc;
      },
      act: (bloc) => bloc.add(const DeleteExpenseEvent('1')),
      verify: (_) {
        verify(() => mockDeleteExpense('1')).called(1);
        verify(() => mockGetExpenses()).called(1);
      },
    );
  });

  group('SearchExpenses', () {
    blocTest<ExpenseBloc, ExpenseState>(
      'filters expenses based on search query when in ExpenseLoaded state',
      build: () => expenseBloc,
      seed: () => ExpenseLoaded(expenses: testExpenses),
      act: (bloc) => bloc.add(const SearchExpenses('Test')),
      expect: () => [
        isA<ExpenseLoaded>().having(
          (state) => state.searchQuery,
          'searchQuery',
          'Test',
        ),
      ],
    );

    blocTest<ExpenseBloc, ExpenseState>(
      'clears search when query is empty',
      build: () => expenseBloc,
      seed: () => ExpenseLoaded(
        expenses: testExpenses,
        searchQuery: 'Test',
      ),
      act: (bloc) => bloc.add(const SearchExpenses('')),
      expect: () => [
        isA<ExpenseLoaded>().having(
          (state) => state.searchQuery,
          'searchQuery',
          isNull,
        ),
      ],
    );
  });

  group('ClearFilters', () {
    blocTest<ExpenseBloc, ExpenseState>(
      'resets filters when ClearFilters is added',
      build: () => expenseBloc,
      seed: () => ExpenseLoaded(
        expenses: testExpenses,
        searchQuery: 'Test',
        filterCategoryId: 'food',
      ),
      act: (bloc) => bloc.add(const ClearFilters()),
      expect: () => [
        isA<ExpenseLoaded>()
            .having((state) => state.searchQuery, 'searchQuery', isNull)
            .having((state) => state.filterCategoryId, 'filterCategoryId', isNull),
      ],
    );
  });
}
