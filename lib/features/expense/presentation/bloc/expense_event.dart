import 'package:equatable/equatable.dart';
import '../../domain/entities/expense.dart';
import '../../../../core/constants/enums.dart';

/// Base class for expense events
abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all expenses
class LoadExpenses extends ExpenseEvent {
  const LoadExpenses();
}

/// Event to load expenses by date range
class LoadExpensesByDateRange extends ExpenseEvent {
  final DateTime startDate;
  final DateTime endDate;

  const LoadExpensesByDateRange({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

/// Event to load expenses by category
class LoadExpensesByCategory extends ExpenseEvent {
  final String categoryId;

  const LoadExpensesByCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

/// Event to load monthly summary
class LoadMonthlySummary extends ExpenseEvent {
  final int year;
  final int month;

  const LoadMonthlySummary({
    required this.year,
    required this.month,
  });

  @override
  List<Object?> get props => [year, month];
}

/// Event to add a new expense
class AddExpenseEvent extends ExpenseEvent {
  final Expense expense;

  const AddExpenseEvent(this.expense);

  @override
  List<Object?> get props => [expense];
}

/// Event to update an expense
class UpdateExpenseEvent extends ExpenseEvent {
  final Expense expense;

  const UpdateExpenseEvent(this.expense);

  @override
  List<Object?> get props => [expense];
}

/// Event to delete an expense
class DeleteExpenseEvent extends ExpenseEvent {
  final String id;

  const DeleteExpenseEvent(this.id);

  @override
  List<Object?> get props => [id];
}

/// Event to search expenses
class SearchExpenses extends ExpenseEvent {
  final String query;

  const SearchExpenses(this.query);

  @override
  List<Object?> get props => [query];
}

/// Event to apply filter
class ApplyFilter extends ExpenseEvent {
  final ExpenseFilterType filterType;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? categoryId;
  final double? minAmount;
  final double? maxAmount;

  const ApplyFilter({
    required this.filterType,
    this.startDate,
    this.endDate,
    this.categoryId,
    this.minAmount,
    this.maxAmount,
  });

  @override
  List<Object?> get props => [
        filterType,
        startDate,
        endDate,
        categoryId,
        minAmount,
        maxAmount,
      ];
}

/// Event to apply sort
class ApplySort extends ExpenseEvent {
  final ExpenseSortType sortType;

  const ApplySort(this.sortType);

  @override
  List<Object?> get props => [sortType];
}

/// Event to clear filters
class ClearFilters extends ExpenseEvent {
  const ClearFilters();
}
