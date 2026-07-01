import 'package:flutter/material.dart';

class TableHeaderData {
  final int flex;
  final String title;
  final Alignment alignment;

  const TableHeaderData({
    required this.flex,
    required this.title,
    this.alignment = Alignment.centerLeft,
  });
}

Widget cellHeader(String title, double flex, {Alignment alignment = Alignment.centerLeft}) {
  return _tableHeaderMarker(
    flex: (flex * 100).toInt(),
    title: title,
    alignment: alignment,
  );
}

Widget cellHeaderName() {
  return cellHeader('Nome', 0.7);
}

Widget cellHeaderAction() {
  return cellHeader('Opções', 0.3, alignment: Alignment.center);
}

TableHeaderData? tableHeaderDataFrom(Widget header) {
  if (header is TableHeaderMarker) return header.data;
  return null;
}

Widget _tableHeaderMarker({
  required int flex,
  required String title,
  required Alignment alignment,
}) {
  return TableHeaderMarker(
    data: TableHeaderData(flex: flex, title: title, alignment: alignment),
  );
}

/// Marcador para a tabela interpretar flex, título e alinhamento.
class TableHeaderMarker extends StatelessWidget {
  final TableHeaderData data;

  const TableHeaderMarker({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
