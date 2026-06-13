import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final String locale;

  CurrencyInputFormatter({required this.locale});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Preserve composing region to avoid breaking accent/diacritic input
    if (newValue.composing.isValid) {
      return newValue;
    }

    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Remove all non-numeric characters
    final String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Treat as cents (divide by 100)
    final double value = double.parse(digitsOnly) / 100;

    // Format according to locale, but without the currency symbol as requested by example "0,01"
    final NumberFormat numberFormat = NumberFormat.currency(
      locale: locale,
      symbol: '',
      decimalDigits: 2,
    );

    final String formattedText = numberFormat.format(value).trim();

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
  static double parse(String text) {
    final String digitsOnly = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return 0.0;
    return double.parse(digitsOnly) / 100;
  }
}
