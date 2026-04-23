import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount, {String symbol = '\$'}) {
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: amount % 1 == 0 ? 0 : 2,
    );
    return formatter.format(amount);
  }

  static String formatCompact(double amount, {String symbol = '\$'}) {
    final formatter = NumberFormat.compactCurrency(symbol: symbol);
    return formatter.format(amount);
  }

  static String formatPerBird(double amount, {String symbol = '\$'}) {
    final formatted = format(amount, symbol: symbol);
    return '$formatted per bird';
  }
}
