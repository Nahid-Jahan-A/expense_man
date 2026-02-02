import 'package:intl/intl.dart';
import '../constants/enums.dart';

/// Currency formatting utility
class CurrencyUtils {
  CurrencyUtils._();

  /// Format amount with currency symbol
  /// Always uses English numerals (0-9) regardless of currency
  static String format(double amount, {Currency currency = Currency.bdt}) {
    final formatter = NumberFormat.currency(
      symbol: currency.symbol,
      decimalDigits: 2,
      locale: 'en_US',
    );
    return formatter.format(amount);
  }

  /// Format amount with compact notation
  static String formatCompact(double amount, {Currency currency = Currency.bdt}) {
    if (amount >= 10000000) {
      return '${currency.symbol}${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '${currency.symbol}${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${currency.symbol}${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '${currency.symbol}${amount.toStringAsFixed(2)}';
  }

  /// Format amount without symbol
  static String formatWithoutSymbol(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return formatter.format(amount);
  }

  /// Parse amount from string
  static double? parse(String value) {
    try {
      // Remove currency symbols and commas
      final cleanValue = value.replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(cleanValue);
    } catch (_) {
      return null;
    }
  }

  /// Get currency symbol
  static String getSymbol(Currency currency) => currency.symbol;

  /// Format for Bengali locale
  static String formatBengali(double amount, {Currency currency = Currency.bdt}) {
    final formatted = formatWithoutSymbol(amount);
    return '${currency.symbol}$formatted';
  }

  /// Convert English digits to Bengali digits
  static String toBengaliDigits(String number) {
    const englishDigits = '0123456789';
    const bengaliDigits = '০১২৩৪৫৬৭৮৯';

    var result = number;
    for (int i = 0; i < englishDigits.length; i++) {
      result = result.replaceAll(englishDigits[i], bengaliDigits[i]);
    }
    return result;
  }

  /// Convert Bengali digits to English digits
  static String toEnglishDigits(String number) {
    const englishDigits = '0123456789';
    const bengaliDigits = '০১২৩৪৫৬৭৮৯';

    var result = number;
    for (int i = 0; i < bengaliDigits.length; i++) {
      result = result.replaceAll(bengaliDigits[i], englishDigits[i]);
    }
    return result;
  }
}
