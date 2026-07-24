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

/// Aceita ISO string ou array Jackson (`[2026, 8, 21]` / `[2026, 8, 21, 19, 30, 0, 0]`).
DateTime? parseApiDateTime(dynamic value) {
  if (value == null) return null;

  if (value is List) {
    if (value.isEmpty) return null;
    final y = _asInt(value[0]);
    final m = value.length > 1 ? _asInt(value[1]) : 1;
    final d = value.length > 2 ? _asInt(value[2]) : 1;
    if (y == null || m == null || d == null) return null;
    final h = value.length > 3 ? (_asInt(value[3]) ?? 0) : 0;
    final min = value.length > 4 ? (_asInt(value[4]) ?? 0) : 0;
    final s = value.length > 5 ? (_asInt(value[5]) ?? 0) : 0;
    return DateTime(y, m, d, h, min, s);
  }

  final text = value.toString().trim();
  if (text.isEmpty || text == 'null') return null;
  return DateTime.tryParse(text);
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
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
