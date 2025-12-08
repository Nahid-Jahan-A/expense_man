import 'package:intl/intl.dart';

/// Date utility functions
class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');
  static final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy');
  static final DateFormat _shortDateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _dayFormat = DateFormat('EEEE');

  /// Format date to string
  static String formatDate(DateTime date) => _dateFormat.format(date);

  /// Format time to string
  static String formatTime(DateTime date) => _timeFormat.format(date);

  /// Format date and time to string
  static String formatDateTime(DateTime date) => _dateTimeFormat.format(date);

  /// Format to month year string
  static String formatMonthYear(DateTime date) => _monthYearFormat.format(date);

  /// Format to short date
  static String formatShortDate(DateTime date) => _shortDateFormat.format(date);

  /// Get day name
  static String getDayName(DateTime date) => _dayFormat.format(date);

  /// Check if two dates are the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return isSameDay(date, now);
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }

  /// Check if date is in this week
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// Check if date is in this month
  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  /// Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Get start of week
  static DateTime startOfWeek(DateTime date) {
    return startOfDay(date.subtract(Duration(days: date.weekday - 1)));
  }

  /// Get end of week
  static DateTime endOfWeek(DateTime date) {
    return endOfDay(date.add(Duration(days: 7 - date.weekday)));
  }

  /// Get start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get end of month
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  /// Get list of dates in month
  static List<DateTime> getDatesInMonth(DateTime date) {
    final firstDay = startOfMonth(date);
    final lastDay = endOfMonth(date);
    final days = <DateTime>[];

    for (var d = firstDay; d.isBefore(lastDay) || isSameDay(d, lastDay); d = d.add(const Duration(days: 1))) {
      days.add(d);
    }

    return days;
  }

  /// Get number of days in month
  static int getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  /// Get relative date string
  static String getRelativeDateString(DateTime date, {bool includeBengali = false}) {
    if (isToday(date)) return includeBengali ? 'আজ' : 'Today';
    if (isYesterday(date)) return includeBengali ? 'গতকাল' : 'Yesterday';
    return formatDate(date);
  }

  /// Parse date from string
  static DateTime? parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (_) {
      try {
        return _dateFormat.parse(dateString);
      } catch (_) {
        return null;
      }
    }
  }

  /// Get months between two dates
  static List<DateTime> getMonthsBetween(DateTime start, DateTime end) {
    final months = <DateTime>[];
    var current = DateTime(start.year, start.month, 1);

    while (current.isBefore(end) || (current.year == end.year && current.month == end.month)) {
      months.add(current);
      current = DateTime(current.year, current.month + 1, 1);
    }

    return months;
  }
}
