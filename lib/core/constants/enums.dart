/// Payment method types
enum PaymentMethod {
  cash('cash', 'Cash', 'নগদ'),
  mobileBanking('mobile_banking', 'Mobile Banking', 'মোবাইল ব্যাংকিং'),
  card('card', 'Card', 'কার্ড');

  final String value;
  final String labelEn;
  final String labelBn;

  const PaymentMethod(this.value, this.labelEn, this.labelBn);

  String getLabel(String locale) => locale == 'bn' ? labelBn : labelEn;

  static PaymentMethod fromValue(String value) {
    return PaymentMethod.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PaymentMethod.cash,
    );
  }
}

/// Default expense categories
enum DefaultCategory {
  medical('medical', 'Medical', 'চিকিৎসা', 0xFF4CAF50, 'medical_services'),
  clothing('clothing', 'Clothing', 'পোশাক', 0xFF9C27B0, 'checkroom'),
  rent('rent', 'Rent', 'ভাড়া', 0xFF2196F3, 'home'),
  bills('bills', 'Bills', 'বিল', 0xFFFF9800, 'receipt_long'),
  transport('transport', 'Transport', 'পরিবহন', 0xFF795548, 'directions_car'),
  food('food', 'Food', 'খাবার', 0xFFE91E63, 'restaurant'),
  shopping('shopping', 'Shopping', 'কেনাকাটা', 0xFF00BCD4, 'shopping_cart'),
  entertainment('entertainment', 'Entertainment', 'বিনোদন', 0xFFFF5722, 'movie'),
  other('other', 'Other', 'অন্যান্য', 0xFF607D8B, 'more_horiz');

  final String id;
  final String nameEn;
  final String nameBn;
  final int color;
  final String icon;

  const DefaultCategory(this.id, this.nameEn, this.nameBn, this.color, this.icon);

  String getName(String locale) => locale == 'bn' ? nameBn : nameEn;
}

/// Theme mode options
enum AppThemeMode {
  light('light', 'Light', 'লাইট'),
  dark('dark', 'Dark', 'ডার্ক'),
  system('system', 'System', 'সিস্টেম');

  final String value;
  final String labelEn;
  final String labelBn;

  const AppThemeMode(this.value, this.labelEn, this.labelBn);

  String getLabel(String locale) => locale == 'bn' ? labelBn : labelEn;

  static AppThemeMode fromValue(String value) {
    return AppThemeMode.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AppThemeMode.system,
    );
  }
}

/// Supported currencies
enum Currency {
  bdt('BDT', '৳', 'Bangladeshi Taka', 'বাংলাদেশি টাকা'),
  usd('USD', '\$', 'US Dollar', 'মার্কিন ডলার'),
  eur('EUR', '€', 'Euro', 'ইউরো'),
  gbp('GBP', '£', 'British Pound', 'ব্রিটিশ পাউন্ড'),
  inr('INR', '₹', 'Indian Rupee', 'ভারতীয় রুপি');

  final String code;
  final String symbol;
  final String nameEn;
  final String nameBn;

  const Currency(this.code, this.symbol, this.nameEn, this.nameBn);

  String getName(String locale) => locale == 'bn' ? nameBn : nameEn;

  static Currency fromCode(String code) {
    return Currency.values.firstWhere(
      (e) => e.code == code,
      orElse: () => Currency.bdt,
    );
  }
}

/// Filter options for expenses
enum ExpenseFilterType {
  all,
  today,
  thisWeek,
  thisMonth,
  custom,
}

/// Sort options for expenses
enum ExpenseSortType {
  dateDesc,
  dateAsc,
  amountDesc,
  amountAsc,
}
