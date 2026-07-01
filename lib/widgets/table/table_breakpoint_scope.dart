import 'package:flutter/material.dart';

/// Fornece o modo de layout da tabela para células e headers decidirem
/// entre layout fixo (scrollável) ou flexível de forma consistente.
class TableBreakpointScope extends InheritedWidget {
  final double tableWidth;
  final bool isScrollable;

  const TableBreakpointScope({
    super.key,
    required this.tableWidth,
    required this.isScrollable,
    required super.child,
  });

  static TableBreakpointScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TableBreakpointScope>();
  }

  static bool isScrollableMode(BuildContext context) {
    final scope = maybeOf(context);
    if (scope != null) return scope.isScrollable;
    return false;
  }

  @override
  bool updateShouldNotify(TableBreakpointScope oldWidget) {
    return oldWidget.tableWidth != tableWidth ||
        oldWidget.isScrollable != isScrollable;
  }
}
