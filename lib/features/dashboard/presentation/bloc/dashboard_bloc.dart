import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../expense/domain/usecases/get_expenses.dart';
import '../../../expense/domain/usecases/get_monthly_summary.dart';
import '../../../../core/extensions/date_extensions.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

/// BLoC for dashboard management
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetExpenses getExpenses;
  final GetMonthlySummary getMonthlySummary;

  DashboardBloc({required this.getExpenses, required this.getMonthlySummary})
    : super(const DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<RefreshDashboard>(_onRefreshDashboard);
    on<ChangeMonth>(_onChangeMonth);
  }

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());

    final now = DateTime.now();
    await _loadDashboardData(emit, now.year, now.month);
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;

    if (currentState is DashboardLoaded) {
      await _loadDashboardData(
        emit,
        currentState.selectedYear,
        currentState.selectedMonth,
      );
    } else {
      final now = DateTime.now();
      await _loadDashboardData(emit, now.year, now.month);
    }
  }

  Future<void> _onChangeMonth(
    ChangeMonth event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    await _loadDashboardData(emit, event.year, event.month);
  }

  Future<void> _loadDashboardData(
    Emitter<DashboardState> emit,
    int year,
    int month,
  ) async {
    final expensesResult = await getExpenses();
    final summaryResult = await getMonthlySummary(year, month);

    expensesResult.fold((failure) => emit(DashboardError(failure)), (expenses) {
      summaryResult.fold((failure) => emit(DashboardError(failure)), (summary) {
        // Calculate today's total
        final todayTotal = expenses
            .where((e) => e.dateTime.isToday)
            .fold<double>(0, (sum, e) => sum + e.amount);

        // Calculate this week's total
        final weekTotal = expenses
            .where((e) => e.dateTime.isThisWeek)
            .fold<double>(0, (sum, e) => sum + e.amount);

        // Get recent expenses (last 5)
        final recentExpenses = expenses.take(5).toList();

        emit(
          DashboardLoaded(
            recentExpenses: recentExpenses,
            monthlySummary: summary,
            todayTotal: todayTotal,
            weekTotal: weekTotal,
            selectedYear: year,
            selectedMonth: month,
          ),
        );
      });
    });
  }
}
