import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../expense/domain/entities/expense.dart';

/// Base class for dashboard states
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

/// Loading state
class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

/// Loaded state with dashboard data
class DashboardLoaded extends DashboardState {
  final List<Expense> recentExpenses;
  final MonthlySummary monthlySummary;
  final double todayTotal;
  final double weekTotal;
  final int selectedYear;
  final int selectedMonth;

  const DashboardLoaded({
    required this.recentExpenses,
    required this.monthlySummary,
    required this.todayTotal,
    required this.weekTotal,
    required this.selectedYear,
    required this.selectedMonth,
  });

  DashboardLoaded copyWith({
    List<Expense>? recentExpenses,
    MonthlySummary? monthlySummary,
    double? todayTotal,
    double? weekTotal,
    int? selectedYear,
    int? selectedMonth,
  }) {
    return DashboardLoaded(
      recentExpenses: recentExpenses ?? this.recentExpenses,
      monthlySummary: monthlySummary ?? this.monthlySummary,
      todayTotal: todayTotal ?? this.todayTotal,
      weekTotal: weekTotal ?? this.weekTotal,
      selectedYear: selectedYear ?? this.selectedYear,
      selectedMonth: selectedMonth ?? this.selectedMonth,
    );
  }

  @override
  List<Object?> get props => [
        recentExpenses,
        monthlySummary,
        todayTotal,
        weekTotal,
        selectedYear,
        selectedMonth,
      ];
}

/// Error state
class DashboardError extends DashboardState {
  final Failure failure;

  const DashboardError(this.failure);

  /// Get the error message
  String get message => failure.message;

  /// Get localized error message
  String getLocalizedMessage(String locale) => failure.getLocalizedMessage(locale);

  @override
  List<Object?> get props => [failure];
}
