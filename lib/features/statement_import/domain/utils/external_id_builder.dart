/// Builds a stable composite dedup key from a statement line's raw
/// identifier (OFX FITID or CSV Identificador) and its signed amount.
///
/// Rationale: Nubank's OFX gives a reversal a FITID of
/// `<original>:reversal` (unique per line already), while Nubank's CSV
/// reuses the exact same Identificador for the reversal row and only
/// flips the amount's sign. Keying on (rawIdentifier, amount) instead of
/// rawIdentifier alone makes both formats collapse to the same two
/// distinct keys per reversal pair (one for the debit, one for the credit
/// reversal) without relying on the OFX-only ":reversal" suffix, and makes
/// an OFX import and a CSV import of the same statement period agree on
/// the same key for the same logical transaction.
class ExternalIdBuilder {
  const ExternalIdBuilder._();

  static final RegExp _reversalSuffix = RegExp(r':reversal$');

  static String build({
    required String rawIdentifier,
    required double amountInCents,
  }) {
    final normalizedId = rawIdentifier.replaceAll(_reversalSuffix, '');
    final amountKey = amountInCents.round();
    return '$normalizedId|$amountKey';
  }
}
