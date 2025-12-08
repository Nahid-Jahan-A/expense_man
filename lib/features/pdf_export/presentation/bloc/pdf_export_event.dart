import 'package:equatable/equatable.dart';
import '../../../expense/domain/entities/expense.dart';
import '../../../category/domain/entities/category.dart';
import '../../../../core/constants/enums.dart';

/// Base class for PDF export events
abstract class PdfExportEvent extends Equatable {
  const PdfExportEvent();

  @override
  List<Object?> get props => [];
}

/// Event to generate monthly PDF report
class GenerateMonthlyReport extends PdfExportEvent {
  final List<Expense> expenses;
  final List<Category> categories;
  final MonthlySummary summary;
  final int year;
  final int month;
  final String languageCode;
  final Currency currency;

  const GenerateMonthlyReport({
    required this.expenses,
    required this.categories,
    required this.summary,
    required this.year,
    required this.month,
    required this.languageCode,
    required this.currency,
  });

  @override
  List<Object?> get props => [
        expenses,
        categories,
        summary,
        year,
        month,
        languageCode,
        currency,
      ];
}

/// Event to reset PDF export state
class ResetPdfExport extends PdfExportEvent {
  const ResetPdfExport();
}
