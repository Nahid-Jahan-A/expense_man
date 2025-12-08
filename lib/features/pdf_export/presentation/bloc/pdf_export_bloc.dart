import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/pdf_generator.dart';
import 'pdf_export_event.dart';
import 'pdf_export_state.dart';

/// BLoC for PDF export management
class PdfExportBloc extends Bloc<PdfExportEvent, PdfExportState> {
  final PdfGenerator _pdfGenerator;

  PdfExportBloc(this._pdfGenerator) : super(const PdfExportInitial()) {
    on<GenerateMonthlyReport>(_onGenerateMonthlyReport);
    on<ResetPdfExport>(_onResetPdfExport);
  }

  Future<void> _onGenerateMonthlyReport(
    GenerateMonthlyReport event,
    Emitter<PdfExportState> emit,
  ) async {
    emit(const PdfExportGenerating());

    try {
      final file = await _pdfGenerator.generateMonthlyReport(
        expenses: event.expenses,
        categories: event.categories,
        summary: event.summary,
        year: event.year,
        month: event.month,
        languageCode: event.languageCode,
        currency: event.currency,
      );

      emit(PdfExportSuccess(
        file: file,
        message: event.languageCode == 'bn'
            ? 'PDF সফলভাবে তৈরি হয়েছে'
            : 'PDF generated successfully',
      ));
    } catch (e) {
      emit(PdfExportError(
        event.languageCode == 'bn'
            ? 'PDF তৈরি করতে ব্যর্থ হয়েছে'
            : 'Failed to generate PDF: ${e.toString()}',
      ));
    }
  }

  void _onResetPdfExport(
    ResetPdfExport event,
    Emitter<PdfExportState> emit,
  ) {
    emit(const PdfExportInitial());
  }
}
