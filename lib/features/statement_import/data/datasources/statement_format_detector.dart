import 'package:due_day/features/statement_import/domain/entities/statement_format.dart';

/// Detects a statement's format from its content, never its file name
/// (IMP-003). Returns null for anything unsupported (IMP-001).
class StatementFormatDetector {
  const StatementFormatDetector._();

  static const List<String> _checkingCsvHeader = [
    'data',
    'valor',
    'identificador',
    'descrição',
  ];
  static const List<String> _cardBillCsvHeader = ['date', 'title', 'amount'];

  static StatementFormat? detect(String content) {
    final text = content.startsWith('\uFEFF') ? content.substring(1) : content;
    final upper = text.toUpperCase();
    if (upper.contains('<OFX>') || upper.contains('OFXHEADER')) {
      return StatementFormat.nubankOfx;
    }

    final firstLine = text
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .firstWhere((line) => line.isNotEmpty, orElse: () => '');
    final header = firstLine
        .split(',')
        .map((cell) => cell.trim().replaceAll('"', '').toLowerCase())
        .toList();

    if (_startsWith(header, _checkingCsvHeader)) {
      return StatementFormat.checkingCsv;
    }
    if (_startsWith(header, _cardBillCsvHeader)) {
      return StatementFormat.cardBillCsv;
    }
    return null;
  }

  static bool _startsWith(List<String> header, List<String> expected) {
    if (header.length < expected.length) return false;
    for (var i = 0; i < expected.length; i++) {
      if (header[i] != expected[i]) return false;
    }
    return true;
  }
}
