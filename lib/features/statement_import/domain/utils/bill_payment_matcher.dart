/// Recognizes card bill payment lines so they arrive as *Ignored* (IMP-008).
///
/// Matching is case- and accent-insensitive and checks the line's start.
class BillPaymentMatcher {
  const BillPaymentMatcher._();

  static const String _checkingPrefix = 'pagamento de fatura';
  static const String _cardPrefix = 'pagamento recebido';

  /// Checking statement memo for paying the card bill.
  static bool isCheckingBillPayment(String memo) =>
      _normalize(memo).startsWith(_checkingPrefix);

  /// Card bill title for the payment received.
  static bool isCardPaymentReceived(String title) =>
      _normalize(title).startsWith(_cardPrefix);

  static const Map<String, String> _accents = {
    'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', //
    'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e', //
    'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i', //
    'ó': 'o', 'ò': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o', //
    'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u', //
    'ç': 'c', 'ñ': 'n',
  };

  static String _normalize(String value) {
    final lower = value.trim().toLowerCase();
    final buffer = StringBuffer();
    for (final rune in lower.runes) {
      final char = String.fromCharCode(rune);
      buffer.write(_accents[char] ?? char);
    }
    return buffer.toString().replaceAll(RegExp(r'\s+'), ' ');
  }
}
