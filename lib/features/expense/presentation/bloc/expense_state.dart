import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/expense.dart';
import '../../../../core/constants/enums.dart';

/// Base class for expense states
abstract class ExpenseState extends Equatable {
  const ExpenseState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ExpenseInitial extends ExpenseState {
  const ExpenseInitial();
}

/// Loading state
class ExpenseLoading extends ExpenseState {
  const ExpenseLoading();
}

/// Loaded state with expenses data
class ExpenseLoaded extends ExpenseState {
  final List<Expense> expenses;
  final List<Expense> filteredExpenses;
  final MonthlySummary? monthlySummary;
  final ExpenseFilterType filterType;
  final ExpenseSortType sortType;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;
  final String? filterCategoryId;
  final double? filterMinAmount;
  final double? filterMaxAmount;
  final String? searchQuery;

  const ExpenseLoaded({
    required this.expenses,
    List<Expense>? filteredExpenses,
    this.monthlySummary,
    this.filterType = ExpenseFilterType.all,
    this.sortType = ExpenseSortType.dateDesc,
    this.filterStartDate,
    this.filterEndDate,
    this.filterCategoryId,
    this.filterMinAmount,
    this.filterMaxAmount,
    this.searchQuery,
  }) : filteredExpenses = filteredExpenses ?? expenses;

  /// Calculate total expense
  double get totalExpense =>
      filteredExpenses.fold(0, (sum, expense) => sum + expense.amount);

  /// Get expenses count
  int get expenseCount => filteredExpenses.length;

  /// Check if filters are applied
  bool get hasFilters =>
      filterType != ExpenseFilterType.all ||
      filterCategoryId != null ||
      filterMinAmount != null ||
      filterMaxAmount != null ||
      (searchQuery?.isNotEmpty ?? false);

  ExpenseLoaded copyWith({
    List<Expense>? expenses,
    List<Expense>? filteredExpenses,
    MonthlySummary? monthlySummary,
    ExpenseFilterType? filterType,
    ExpenseSortType? sortType,
    DateTime? filterStartDate,
    DateTime? filterEndDate,
    String? filterCategoryId,
    double? filterMinAmount,
    double? filterMaxAmount,
    String? searchQuery,
    bool clearMonthlySummary = false,
    bool clearStartDate = false,
    bool clearEndDate = false,
    bool clearCategoryId = false,
    bool clearMinAmount = false,
    bool clearMaxAmount = false,
    bool clearSearchQuery = false,
  }) {
    return ExpenseLoaded(
      expenses: expenses ?? this.expenses,
      filteredExpenses: filteredExpenses ?? this.filteredExpenses,
      monthlySummary:
          clearMonthlySummary ? null : (monthlySummary ?? this.monthlySummary),
      filterType: filterType ?? this.filterType,
      sortType: sortType ?? this.sortType,
      filterStartDate:
          clearStartDate ? null : (filterStartDate ?? this.filterStartDate),
      filterEndDate:
          clearEndDate ? null : (filterEndDate ?? this.filterEndDate),
      filterCategoryId:
          clearCategoryId ? null : (filterCategoryId ?? this.filterCategoryId),
      filterMinAmount:
          clearMinAmount ? null : (filterMinAmount ?? this.filterMinAmount),
      filterMaxAmount:
          clearMaxAmount ? null : (filterMaxAmount ?? this.filterMaxAmount),
      searchQuery:
          clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
    );
  }

  @override
  List<Object?> get props => [
        expenses,
        filteredExpenses,
        monthlySummary,
        filterType,
        sortType,
        filterStartDate,
        filterEndDate,
        filterCategoryId,
        filterMinAmount,
        filterMaxAmount,
        searchQuery,
      ];
}

/// Error state
class ExpenseError extends ExpenseState {
  final Failure failure;

  const ExpenseError(this.failure);

  /// Get the error message
  String get message => failure.message;

  /// Get localized error message
  String getLocalizedMessage(String locale) => failure.getLocalizedMessage(locale);

  @override
  List<Object?> get props => [failure];
}

/// State for expense operation success
class ExpenseOperationSuccess extends ExpenseState {
  final String message;
  final ExpenseLoaded previousState;

  const ExpenseOperationSuccess({
    required this.message,
    required this.previousState,
  });

  @override
  List<Object?> get props => [message, previousState];
}
