import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/expense.dart';
import '../../domain/usecases/add_expense.dart';
import '../../domain/usecases/delete_expense.dart';
import '../../domain/usecases/get_expenses.dart';
import '../../domain/usecases/get_expenses_by_date_range.dart';
import '../../domain/usecases/get_monthly_summary.dart';
import '../../domain/usecases/update_expense.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/extensions/date_extensions.dart';
import 'expense_event.dart';
import 'expense_state.dart';

/// BLoC for expense management
class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final GetExpenses getExpenses;
  final GetExpensesByDateRange getExpensesByDateRange;
  final GetMonthlySummary getMonthlySummary;
  final AddExpense addExpense;
  final UpdateExpense updateExpense;
  final DeleteExpense deleteExpense;

  ExpenseBloc({
    required this.getExpenses,
    required this.getExpensesByDateRange,
    required this.getMonthlySummary,
    required this.addExpense,
    required this.updateExpense,
    required this.deleteExpense,
  }) : super(const ExpenseInitial()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<LoadExpensesByDateRange>(_onLoadExpensesByDateRange);
    on<LoadMonthlySummary>(_onLoadMonthlySummary);
    on<AddExpenseEvent>(_onAddExpense);
    on<UpdateExpenseEvent>(_onUpdateExpense);
    on<DeleteExpenseEvent>(_onDeleteExpense);
    on<SearchExpenses>(_onSearchExpenses);
    on<ApplyFilter>(_onApplyFilter);
    on<ApplySort>(_onApplySort);
    on<ClearFilters>(_onClearFilters);
  }

  Future<void> _onLoadExpenses(
    LoadExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(const ExpenseLoading());

    final result = await getExpenses();
    result.fold(
      (failure) => emit(ExpenseError(failure)),
      (expenses) => emit(ExpenseLoaded(expenses: expenses)),
    );
  }

  Future<void> _onLoadExpensesByDateRange(
    LoadExpensesByDateRange event,
    Emitter<ExpenseState> emit,
  ) async {
    final currentState = state;

    if (currentState is ExpenseLoaded) {
      final result = await getExpensesByDateRange(
        event.startDate,
        event.endDate,
      );

      result.fold(
        (failure) => emit(ExpenseError(failure)),
        (expenses) => emit(currentState.copyWith(
          filteredExpenses: expenses,
          filterType: ExpenseFilterType.custom,
          filterStartDate: event.startDate,
          filterEndDate: event.endDate,
        )),
      );
    } else {
      emit(const ExpenseLoading());
      final result = await getExpensesByDateRange(
        event.startDate,
        event.endDate,
      );

      result.fold(
        (failure) => emit(ExpenseError(failure)),
        (expenses) => emit(ExpenseLoaded(
          expenses: expenses,
          filterType: ExpenseFilterType.custom,
          filterStartDate: event.startDate,
          filterEndDate: event.endDate,
        )),
      );
    }
  }

  Future<void> _onLoadMonthlySummary(
    LoadMonthlySummary event,
    Emitter<ExpenseState> emit,
  ) async {
    final currentState = state;

    final result = await getMonthlySummary(event.year, event.month);

    if (currentState is ExpenseLoaded) {
      result.fold(
        (failure) => emit(ExpenseError(failure)),
        (summary) => emit(currentState.copyWith(monthlySummary: summary)),
      );
    } else {
      final expensesResult = await getExpenses();
      expensesResult.fold(
        (failure) => emit(ExpenseError(failure)),
        (expenses) {
          result.fold(
            (failure) => emit(ExpenseError(failure)),
            (summary) => emit(ExpenseLoaded(
              expenses: expenses,
              monthlySummary: summary,
            )),
          );
        },
      );
    }
  }

  Future<void> _onAddExpense(
    AddExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    final currentState = state;

    final result = await addExpense(event.expense);

    if (result.isLeft()) {
      emit(ExpenseError(result.fold((l) => l, (_) => '')));
      return;
    }

    // Reload expenses after adding
    final expensesResult = await getExpenses();
    expensesResult.fold(
      (failure) => emit(ExpenseError(failure)),
      (expenses) {
        if (currentState is ExpenseLoaded) {
          final filteredExpenses = _applyCurrentFilters(expenses, currentState);
          emit(ExpenseOperationSuccess(
            message: 'Expense added successfully',
            previousState: currentState.copyWith(
              expenses: expenses,
              filteredExpenses: filteredExpenses,
            ),
          ));
          emit(currentState.copyWith(
            expenses: expenses,
            filteredExpenses: filteredExpenses,
          ));
        } else {
          emit(ExpenseLoaded(expenses: expenses));
        }
      },
    );
  }

  Future<void> _onUpdateExpense(
    UpdateExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    final currentState = state;

    final result = await updateExpense(event.expense);

    if (result.isLeft()) {
      emit(ExpenseError(result.fold((l) => l, (_) => '')));
      return;
    }

    final expensesResult = await getExpenses();
    expensesResult.fold(
      (failure) => emit(ExpenseError(failure)),
      (expenses) {
        if (currentState is ExpenseLoaded) {
          final filteredExpenses = _applyCurrentFilters(expenses, currentState);
          emit(ExpenseOperationSuccess(
            message: 'Expense updated successfully',
            previousState: currentState.copyWith(
              expenses: expenses,
              filteredExpenses: filteredExpenses,
            ),
          ));
          emit(currentState.copyWith(
            expenses: expenses,
            filteredExpenses: filteredExpenses,
          ));
        } else {
          emit(ExpenseLoaded(expenses: expenses));
        }
      },
    );
  }

  Future<void> _onDeleteExpense(
    DeleteExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    final currentState = state;

    final result = await deleteExpense(event.id);

    if (result.isLeft()) {
      emit(ExpenseError(result.fold((l) => l, (_) => '')));
      return;
    }

    final expensesResult = await getExpenses();
    expensesResult.fold(
      (failure) => emit(ExpenseError(failure)),
      (expenses) {
        if (currentState is ExpenseLoaded) {
          // Re-apply current filters to the new expenses list
          final filteredExpenses = _applyCurrentFilters(expenses, currentState);
          emit(ExpenseOperationSuccess(
            message: 'Expense deleted successfully',
            previousState: currentState.copyWith(
              expenses: expenses,
              filteredExpenses: filteredExpenses,
            ),
          ));
          emit(currentState.copyWith(
            expenses: expenses,
            filteredExpenses: filteredExpenses,
          ));
        } else {
          emit(ExpenseLoaded(expenses: expenses));
        }
      },
    );
  }

  List<Expense> _applyCurrentFilters(List<Expense> expenses, ExpenseLoaded currentState) {
    var filtered = expenses.toList();

    // Apply search query
    if (currentState.searchQuery?.isNotEmpty ?? false) {
      final query = currentState.searchQuery!.toLowerCase();
      filtered = filtered.where((expense) {
        return (expense.note?.toLowerCase().contains(query) ?? false) ||
            expense.amount.toString().contains(query);
      }).toList();
    }

    // Apply date filter
    switch (currentState.filterType) {
      case ExpenseFilterType.today:
        filtered = filtered.where((e) => _isToday(e.dateTime)).toList();
        break;
      case ExpenseFilterType.thisWeek:
        filtered = filtered.where((e) => _isThisWeek(e.dateTime)).toList();
        break;
      case ExpenseFilterType.thisMonth:
        filtered = filtered.where((e) => _isThisMonth(e.dateTime)).toList();
        break;
      case ExpenseFilterType.custom:
        if (currentState.filterStartDate != null && currentState.filterEndDate != null) {
          filtered = filtered.where((e) {
            return e.dateTime.isAfter(
                    currentState.filterStartDate!.subtract(const Duration(days: 1))) &&
                e.dateTime.isBefore(
                    currentState.filterEndDate!.add(const Duration(days: 1)));
          }).toList();
        }
        break;
      case ExpenseFilterType.all:
        break;
    }

    // Apply category filter
    if (currentState.filterCategoryId != null) {
      filtered = filtered.where((e) => e.categoryId == currentState.filterCategoryId).toList();
    }

    // Apply sort
    filtered = _sortExpenses(filtered, currentState.sortType);

    return filtered;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  bool _isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  void _onSearchExpenses(
    SearchExpenses event,
    Emitter<ExpenseState> emit,
  ) {
    final currentState = state;

    if (currentState is ExpenseLoaded) {
      if (event.query.isEmpty) {
        emit(currentState.copyWith(
          filteredExpenses: currentState.expenses,
          clearSearchQuery: true,
        ));
      } else {
        final query = event.query.toLowerCase();
        final filtered = currentState.expenses.where((expense) {
          return (expense.note?.toLowerCase().contains(query) ?? false) ||
              expense.amount.toString().contains(query);
        }).toList();

        emit(currentState.copyWith(
          filteredExpenses: filtered,
          searchQuery: event.query,
        ));
      }
    }
  }

  void _onApplyFilter(
    ApplyFilter event,
    Emitter<ExpenseState> emit,
  ) {
    final currentState = state;

    if (currentState is ExpenseLoaded) {
      var filtered = currentState.expenses.toList();

      // Apply date filter
      switch (event.filterType) {
        case ExpenseFilterType.today:
          filtered = filtered
              .where((e) => e.dateTime.isToday)
              .toList();
          break;
        case ExpenseFilterType.thisWeek:
          filtered = filtered
              .where((e) => e.dateTime.isThisWeek)
              .toList();
          break;
        case ExpenseFilterType.thisMonth:
          filtered = filtered
              .where((e) => e.dateTime.isThisMonth)
              .toList();
          break;
        case ExpenseFilterType.custom:
          if (event.startDate != null && event.endDate != null) {
            filtered = filtered.where((e) {
              return e.dateTime.isAfter(
                      event.startDate!.subtract(const Duration(days: 1))) &&
                  e.dateTime.isBefore(
                      event.endDate!.add(const Duration(days: 1)));
            }).toList();
          }
          break;
        case ExpenseFilterType.all:
          break;
      }

      // Apply category filter
      if (event.categoryId != null) {
        filtered = filtered
            .where((e) => e.categoryId == event.categoryId)
            .toList();
      }

      // Apply amount filter
      if (event.minAmount != null) {
        filtered = filtered
            .where((e) => e.amount >= event.minAmount!)
            .toList();
      }
      if (event.maxAmount != null) {
        filtered = filtered
            .where((e) => e.amount <= event.maxAmount!)
            .toList();
      }

      // Apply current sort
      filtered = _sortExpenses(filtered, currentState.sortType);

      emit(currentState.copyWith(
        filteredExpenses: filtered,
        filterType: event.filterType,
        filterStartDate: event.startDate,
        filterEndDate: event.endDate,
        filterCategoryId: event.categoryId,
        filterMinAmount: event.minAmount,
        filterMaxAmount: event.maxAmount,
      ));
    }
  }

  void _onApplySort(
    ApplySort event,
    Emitter<ExpenseState> emit,
  ) {
    final currentState = state;

    if (currentState is ExpenseLoaded) {
      final sorted = _sortExpenses(
        currentState.filteredExpenses.toList(),
        event.sortType,
      );

      emit(currentState.copyWith(
        filteredExpenses: sorted,
        sortType: event.sortType,
      ));
    }
  }

  void _onClearFilters(
    ClearFilters event,
    Emitter<ExpenseState> emit,
  ) {
    final currentState = state;

    if (currentState is ExpenseLoaded) {
      emit(ExpenseLoaded(
        expenses: currentState.expenses,
        filteredExpenses: currentState.expenses,
        monthlySummary: currentState.monthlySummary,
        filterType: ExpenseFilterType.all,
        sortType: ExpenseSortType.dateDesc,
      ));
    }
  }

  List<Expense> _sortExpenses(List<Expense> expenses, ExpenseSortType sortType) {
    switch (sortType) {
      case ExpenseSortType.dateDesc:
        expenses.sort((a, b) => b.dateTime.compareTo(a.dateTime));
        break;
      case ExpenseSortType.dateAsc:
        expenses.sort((a, b) => a.dateTime.compareTo(b.dateTime));
        break;
      case ExpenseSortType.amountDesc:
        expenses.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case ExpenseSortType.amountAsc:
        expenses.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }
    return expenses;
  }
}
