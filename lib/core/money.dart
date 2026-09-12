import '../models/invoice.dart';
import 'theme.dart';

/// Currency-aware money totals.
///
/// Invoices can each carry their own currency, so aggregate figures must never
/// blindly add different currencies together (₹50,000 + د.إ5,000 is meaningless).
/// These helpers group by currency and render each group with its own symbol,
/// e.g. "₹1.2L · د.إ5.0K". A single-currency set renders as one value.
class MoneyTotals {
  static String grouped(
    Iterable<Invoice> invoices,
    double Function(Invoice) amount,
  ) {
    final totals = <String, double>{};
    for (final invoice in invoices) {
      totals[invoice.currency] = (totals[invoice.currency] ?? 0) + amount(invoice);
    }
    return fromMap(totals);
  }

  /// Formats an already-aggregated `{currency: amount}` map, dropping zero rows.
  static String fromMap(Map<String, double> totals) {
    final parts = totals.entries
        .where((e) => e.value != 0)
        .map((e) => AppCurrency.formatCompactFor(e.key, e.value))
        .toList();
    if (parts.isEmpty) return AppCurrency.formatCompact(0);
    return parts.join('  ·  ');
  }
}
