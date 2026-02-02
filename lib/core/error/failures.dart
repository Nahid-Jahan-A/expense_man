import 'package:equatable/equatable.dart';

/// Base class for all failures in the application.
/// Using sealed class for exhaustive pattern matching.
sealed class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

/// Failure related to cache/local storage operations
final class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
  });

  factory CacheFailure.read([String? details]) => CacheFailure(
        message: 'Failed to read from cache${details != null ? ': $details' : ''}',
        code: 'CACHE_READ_ERROR',
      );

  factory CacheFailure.write([String? details]) => CacheFailure(
        message: 'Failed to write to cache${details != null ? ': $details' : ''}',
        code: 'CACHE_WRITE_ERROR',
      );

  factory CacheFailure.delete([String? details]) => CacheFailure(
        message: 'Failed to delete from cache${details != null ? ': $details' : ''}',
        code: 'CACHE_DELETE_ERROR',
      );

  factory CacheFailure.notFound([String? details]) => CacheFailure(
        message: 'Item not found in cache${details != null ? ': $details' : ''}',
        code: 'CACHE_NOT_FOUND',
      );
}

/// Failure related to validation errors
final class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    required super.message,
    super.code,
    this.fieldErrors,
  });

  factory ValidationFailure.invalidInput(String field, [String? details]) => ValidationFailure(
        message: 'Invalid input for $field${details != null ? ': $details' : ''}',
        code: 'VALIDATION_INVALID_INPUT',
        fieldErrors: {field: details ?? 'Invalid value'},
      );

  factory ValidationFailure.required(String field) => ValidationFailure(
        message: '$field is required',
        code: 'VALIDATION_REQUIRED',
        fieldErrors: {field: 'This field is required'},
      );

  factory ValidationFailure.custom(String message, [Map<String, String>? fieldErrors]) => ValidationFailure(
        message: message,
        code: 'VALIDATION_ERROR',
        fieldErrors: fieldErrors,
      );

  @override
  List<Object?> get props => [message, code, fieldErrors];
}

/// Failure related to unexpected errors
final class UnexpectedFailure extends Failure {
  final Object? exception;
  final StackTrace? stackTrace;

  const UnexpectedFailure({
    required super.message,
    super.code,
    this.exception,
    this.stackTrace,
  });

  factory UnexpectedFailure.fromException(Object exception, [StackTrace? stackTrace]) => UnexpectedFailure(
        message: 'An unexpected error occurred: ${exception.toString()}',
        code: 'UNEXPECTED_ERROR',
        exception: exception,
        stackTrace: stackTrace,
      );

  @override
  List<Object?> get props => [message, code, exception];
}

/// Failure related to PDF generation
final class PdfFailure extends Failure {
  const PdfFailure({
    required super.message,
    super.code,
  });

  factory PdfFailure.generation([String? details]) => PdfFailure(
        message: 'Failed to generate PDF${details != null ? ': $details' : ''}',
        code: 'PDF_GENERATION_ERROR',
      );

  factory PdfFailure.save([String? details]) => PdfFailure(
        message: 'Failed to save PDF${details != null ? ': $details' : ''}',
        code: 'PDF_SAVE_ERROR',
      );
}

/// Failure related to permission issues
final class PermissionFailure extends Failure {
  const PermissionFailure({
    required super.message,
    super.code,
  });

  factory PermissionFailure.denied(String permission) => PermissionFailure(
        message: '$permission permission denied',
        code: 'PERMISSION_DENIED',
      );

  factory PermissionFailure.permanentlyDenied(String permission) => PermissionFailure(
        message: '$permission permission permanently denied. Please enable in settings.',
        code: 'PERMISSION_PERMANENTLY_DENIED',
      );
}

/// Failure related to backup operations
final class BackupFailure extends Failure {
  const BackupFailure({
    required super.message,
    super.code,
  });

  factory BackupFailure.creation([String? details]) => BackupFailure(
        message: 'Failed to create backup${details != null ? ': $details' : ''}',
        code: 'BACKUP_CREATION_ERROR',
      );

  factory BackupFailure.import([String? details]) => BackupFailure(
        message: 'Failed to import backup${details != null ? ': $details' : ''}',
        code: 'BACKUP_IMPORT_ERROR',
      );

  factory BackupFailure.validation([String? details]) => BackupFailure(
        message: 'Backup validation failed${details != null ? ': $details' : ''}',
        code: 'BACKUP_VALIDATION_ERROR',
      );

  factory BackupFailure.read([String? details]) => BackupFailure(
        message: 'Failed to read backup${details != null ? ': $details' : ''}',
        code: 'BACKUP_READ_ERROR',
      );

  factory BackupFailure.deletion([String? details]) => BackupFailure(
        message: 'Failed to delete backup${details != null ? ': $details' : ''}',
        code: 'BACKUP_DELETE_ERROR',
      );
}

/// Extension to get user-friendly error messages
extension FailureX on Failure {
  /// Returns a localized error message based on locale
  String getLocalizedMessage(String locale) {
    // Default to the message itself
    // You can extend this to support multiple languages
    if (locale == 'bn') {
      return _getBengaliMessage();
    }
    return message;
  }

  String _getBengaliMessage() {
    return switch (this) {
      CacheFailure(code: 'CACHE_READ_ERROR') => 'ডেটা পড়তে ব্যর্থ হয়েছে',
      CacheFailure(code: 'CACHE_WRITE_ERROR') => 'ডেটা সংরক্ষণ করতে ব্যর্থ হয়েছে',
      CacheFailure(code: 'CACHE_DELETE_ERROR') => 'ডেটা মুছতে ব্যর্থ হয়েছে',
      CacheFailure(code: 'CACHE_NOT_FOUND') => 'ডেটা পাওয়া যায়নি',
      ValidationFailure(code: 'VALIDATION_INVALID_INPUT') => 'অবৈধ ইনপুট',
      ValidationFailure(code: 'VALIDATION_REQUIRED') => 'এই ক্ষেত্রটি আবশ্যক',
      UnexpectedFailure() => 'একটি অপ্রত্যাশিত ত্রুটি ঘটেছে',
      PdfFailure(code: 'PDF_GENERATION_ERROR') => 'পিডিএফ তৈরি করতে ব্যর্থ হয়েছে',
      PdfFailure(code: 'PDF_SAVE_ERROR') => 'পিডিএফ সংরক্ষণ করতে ব্যর্থ হয়েছে',
      PermissionFailure(code: 'PERMISSION_DENIED') => 'অনুমতি প্রত্যাখ্যান করা হয়েছে',
      PermissionFailure(code: 'PERMISSION_PERMANENTLY_DENIED') => 'অনুমতি স্থায়ীভাবে প্রত্যাখ্যান করা হয়েছে',
      BackupFailure(code: 'BACKUP_CREATION_ERROR') => 'ব্যাকআপ তৈরি করতে ব্যর্থ হয়েছে',
      BackupFailure(code: 'BACKUP_IMPORT_ERROR') => 'ব্যাকআপ আমদানি করতে ব্যর্থ হয়েছে',
      BackupFailure(code: 'BACKUP_VALIDATION_ERROR') => 'ব্যাকআপ যাচাই করতে ব্যর্থ হয়েছে',
      BackupFailure(code: 'BACKUP_READ_ERROR') => 'ব্যাকআপ পড়তে ব্যর্থ হয়েছে',
      BackupFailure(code: 'BACKUP_DELETE_ERROR') => 'ব্যাকআপ মুছতে ব্যর্থ হয়েছে',
      _ => message,
    };
  }
}
