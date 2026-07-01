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

double? parseMoneyBr(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;

  final normalized = trimmed
      .replaceAll('R\$', '')
      .replaceAll(RegExp(r'\s'), '')
      .replaceAll('.', '')
      .replaceAll(',', '.');

  return double.tryParse(normalized);
}

String formatMoneyInput(double value) {
  return value.toStringAsFixed(2).replaceAll('.', ',');
}
