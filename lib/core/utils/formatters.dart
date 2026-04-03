import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  /// Format large numbers: $1.2B, $345M, $12.5K
  static String compactUsd(num value) {
    if (value >= 1e12) {
      return '\$${(value / 1e12).toStringAsFixed(2)}T';
    } else if (value >= 1e9) {
      return '\$${(value / 1e9).toStringAsFixed(2)}B';
    } else if (value >= 1e6) {
      return '\$${(value / 1e6).toStringAsFixed(2)}M';
    } else if (value >= 1e3) {
      return '\$${(value / 1e3).toStringAsFixed(1)}K';
    }
    return '\$${value.toStringAsFixed(2)}';
  }

  /// Format percentage: +3.5%, -1.2%
  static String percent(num value, {bool showSign = true}) {
    final sign = showSign && value > 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(2)}%';
  }

  /// Format APY: 5.2%
  static String apy(num value) {
    return '${value.toStringAsFixed(1)}%';
  }

  /// Format plain USD: $67,234
  static String usd(num value) {
    final formatter = NumberFormat('#,##0', 'en_US');
    return '\$${formatter.format(value)}';
  }

  /// Format date: 03/30
  static String shortDate(DateTime date) {
    return DateFormat('MM/dd').format(date);
  }

  /// Format time: 12:34
  static String time(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }
}
