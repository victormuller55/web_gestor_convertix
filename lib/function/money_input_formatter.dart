import 'package:flutter/services.dart';

/// Aceita apenas dígitos e formata como moeda pt-BR (centavos).
/// Digitar `1000` → `10,00`; digitar `100000` → `1.000,00`.
class MoneyInputFormatter extends TextInputFormatter {
  const MoneyInputFormatter();

  static String formatFromCents(int cents) {
    final negative = cents < 0;
    final abs = cents.abs();
    final intPart = abs ~/ 100;
    final frac = (abs % 100).toString().padLeft(2, '0');
    final withDots = _groupThousands(intPart);
    final formatted = '$withDots,$frac';
    return negative ? '-$formatted' : formatted;
  }

  static String formatFromDouble(double value) {
    return formatFromCents((value * 100).round());
  }

  static String _groupThousands(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Limita a ~999.999.999,99 (11 dígitos de centavos).
    final clipped = digits.length > 11 ? digits.substring(0, 11) : digits;
    final cents = int.parse(clipped);
    final formatted = formatFromCents(cents);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
