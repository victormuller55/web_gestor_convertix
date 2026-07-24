import 'package:web_gestor_site_covertix/function/money_input_formatter.dart';

String formatDateTable(DateTime? value) {
  if (value == null) return '—';
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  return '$day/$month/${value.year}';
}

String formatDateForm(DateTime? value) {
  if (value == null) return '';
  return formatDateTable(value);
}

DateTime? parseFormDate(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;

  final parts = trimmed.split('/');
  if (parts.length != 3) return null;

  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);
  if (day == null || month == null || year == null) return null;

  return DateTime(year, month, day);
}

String formatApiDate(DateTime date) {
  final y = date.year;
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// Converte string ISO-8601 da API em [DateTime] local.
///
/// Exemplos:
/// - `"2026-07-01T19:29:25.539960"` → data/hora local (sem inventar offset)
/// - `"2026-07-01"` → meia-noite local (evita UTC que o [DateTime.tryParse] aplica em date-only)
DateTime? parseApiDateTime(dynamic value) {
  if (value == null) return null;

  final text = value.toString().trim();
  if (text.isEmpty || text == 'null') return null;

  // LocalDate da API: "YYYY-MM-DD" — força horário local.
  if (text.length == 10 && RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(text)) {
    return DateTime.tryParse('${text}T00:00:00');
  }

  return DateTime.tryParse(text);
}

/// Converte texto de valor no formato brasileiro (`1.234,56` ou `1234,56`) em double.
double? parseMoneyBr(String? raw) {
  if (raw == null) return null;
  final cleaned = raw.trim().replaceAll(RegExp(r'[^\d,.-]'), '');
  if (cleaned.isEmpty) return null;

  final normalized = cleaned.contains(',')
      ? cleaned.replaceAll('.', '').replaceAll(',', '.')
      : cleaned;

  return double.tryParse(normalized);
}

/// Formata double para exibição/edição no input (`1.234,56`).
String formatMoneyInput(double value) {
  return MoneyInputFormatter.formatFromDouble(value);
}
