import 'package:intl/intl.dart';

/// Sri Lankan Rupee (LKR) currency formatting
class CurrencyFormatter {
  CurrencyFormatter._();

  static final _format = NumberFormat.currency(
    locale: 'si_LK',
    symbol: 'LKR ',
    decimalDigits: 0,
  );

  static String format(double amount) => _format.format(amount);
  static String formatInt(int amount)  => _format.format(amount);
}
