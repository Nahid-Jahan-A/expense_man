import '../utils/date_utils.dart';

/// Extension methods for DateTime
extension DateTimeExtensions on DateTime {
  /// Format to date string
  String get formatted => AppDateUtils.formatDate(this);

  /// Format to time string
  String get formattedTime => AppDateUtils.formatTime(this);

  /// Format to date time string
  String get formattedDateTime => AppDateUtils.formatDateTime(this);

  /// Format to month year string
  String get formattedMonthYear => AppDateUtils.formatMonthYear(this);

  /// Format to short date
  String get formattedShort => AppDateUtils.formatShortDate(this);

  /// Get day name
  String get dayName => AppDateUtils.getDayName(this);

  /// Check if today
  bool get isToday => AppDateUtils.isToday(this);

  /// Check if yesterday
  bool get isYesterday => AppDateUtils.isYesterday(this);

  /// Check if this week
  bool get isThisWeek => AppDateUtils.isThisWeek(this);

  /// Check if this month
  bool get isThisMonth => AppDateUtils.isThisMonth(this);

  /// Get start of day
  DateTime get startOfDay => AppDateUtils.startOfDay(this);

  /// Get end of day
  DateTime get endOfDay => AppDateUtils.endOfDay(this);

  /// Get start of week
  DateTime get startOfWeek => AppDateUtils.startOfWeek(this);

  /// Get end of week
  DateTime get endOfWeek => AppDateUtils.endOfWeek(this);

  /// Get start of month
  DateTime get startOfMonth => AppDateUtils.startOfMonth(this);

  /// Get end of month
  DateTime get endOfMonth => AppDateUtils.endOfMonth(this);

  /// Check if same day as another date
  bool isSameDay(DateTime other) => AppDateUtils.isSameDay(this, other);

  /// Check if same month as another date
  bool isSameMonth(DateTime other) {
    return year == other.year && month == other.month;
  }

  /// Get relative date string
  String get relativeDateString => AppDateUtils.getRelativeDateString(this);

  /// Get days in month
  int get daysInMonth => AppDateUtils.getDaysInMonth(this);

  /// Get dates in month
  List<DateTime> get datesInMonth => AppDateUtils.getDatesInMonth(this);

  /// Add days
  DateTime addDays(int days) => add(Duration(days: days));

  /// Subtract days
  DateTime subtractDays(int days) => subtract(Duration(days: days));

  /// Add months
  DateTime addMonths(int months) => DateTime(year, month + months, day);

  /// Subtract months
  DateTime subtractMonths(int months) => DateTime(year, month - months, day);

  /// Copy with modified values
  DateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
  }) {
    return DateTime(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
      millisecond ?? this.millisecond,
      microsecond ?? this.microsecond,
    );
  }
}
