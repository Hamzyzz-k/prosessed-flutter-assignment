import 'package:intl/intl.dart';

/// Formatting helpers shared across features.
abstract final class Formatters {
  static final _currency = NumberFormat.currency(locale: 'en_US', symbol: r'$');

  /// `12.5` -> `$12.50`. DummyJSON prices are in US dollars.
  static String price(num value) => _currency.format(value);

  /// `12.48` -> `12%`.
  static String percent(num value) => '${value.round()}%';

  /// `4.567` -> `4.6`.
  static String rating(num value) => value.toStringAsFixed(1);

  /// `2025-04-30T09:41:02Z` -> `30 Apr 2025` in the given locale.
  static String date(DateTime date, [String? locale]) =>
      DateFormat.yMMMd(locale).format(date.toLocal());
}
