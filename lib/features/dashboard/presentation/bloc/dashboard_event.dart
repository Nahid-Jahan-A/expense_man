import 'package:equatable/equatable.dart';

/// Base class for dashboard events
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load dashboard data
class LoadDashboard extends DashboardEvent {
  const LoadDashboard();
}

/// Event to refresh dashboard
class RefreshDashboard extends DashboardEvent {
  const RefreshDashboard();
}

/// Event to change selected month
class ChangeMonth extends DashboardEvent {
  final int year;
  final int month;

  const ChangeMonth({required this.year, required this.month});

  @override
  List<Object?> get props => [year, month];
}
