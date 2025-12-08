import 'dart:io';
import 'package:equatable/equatable.dart';

/// Base class for PDF export states
abstract class PdfExportState extends Equatable {
  const PdfExportState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class PdfExportInitial extends PdfExportState {
  const PdfExportInitial();
}

/// Generating PDF state
class PdfExportGenerating extends PdfExportState {
  const PdfExportGenerating();
}

/// PDF generated successfully
class PdfExportSuccess extends PdfExportState {
  final File file;
  final String message;

  const PdfExportSuccess({
    required this.file,
    required this.message,
  });

  @override
  List<Object?> get props => [file, message];
}

/// PDF export failed
class PdfExportError extends PdfExportState {
  final String message;

  const PdfExportError(this.message);

  @override
  List<Object?> get props => [message];
}
