import 'package:intl/intl.dart';
import '../config/app_config.dart';

class CurrencyUtils {
  static String format(num? amount, {String? currencyCode, int decimalDigits = 2}) {
    if (amount == null) return '${currencyCode ?? AppConfig.defaultCurrency} 0.00';
    final formatter = NumberFormat.currency(
      symbol: '${currencyCode ?? AppConfig.defaultCurrency} ',
      decimalDigits: decimalDigits,
    );
    return formatter.format(amount);
  }

  static String formatCompact(num? amount, {String? currencyCode}) {
    if (amount == null) return '${currencyCode ?? AppConfig.defaultCurrency} 0';
    if (amount >= 1000000) {
      return '${currencyCode ?? AppConfig.defaultCurrency} ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${currencyCode ?? AppConfig.defaultCurrency} ${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amount, currencyCode: currencyCode, decimalDigits: 0);
  }
}
