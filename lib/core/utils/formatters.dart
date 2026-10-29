import 'package:intl/intl.dart';

abstract final class AppFormatters {
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 2,
  );

  static final NumberFormat _decimalFormatter = NumberFormat(
    '#,##0.00',
    'en_US',
  );

  static final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy', 'en_US');

  static String formatCurrency(double amount) {
    return _currencyFormatter.format(amount);
  }

  static String formatDecimal(double amount) {
    return _decimalFormatter.format(amount);
  }

  static String formatDate(DateTime date) {
    return _dateFormatter.format(date);
  }
}
