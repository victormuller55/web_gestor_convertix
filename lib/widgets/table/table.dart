import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/const/app_theme.dart';
import 'package:web_gestor_site_covertix/app_config/const/covertix_colors.dart';
import 'package:web_gestor_site_covertix/app_config/const/panel_header_style.dart';
import 'package:web_gestor_site_covertix/widgets/table/table_breakpoint_scope.dart';
import 'package:web_gestor_site_covertix/widgets/table/table_layout.dart';
import 'package:web_gestor_site_covertix/widgets/table/table_cell.dart';
import 'package:web_gestor_site_covertix/widgets/table/table_header.dart';

class AppTableRow extends StatefulWidget {
  final List<Widget> columns;

  const AppTableRow({super.key, required this.columns});

  @override
  State<AppTableRow> createState() => _AppTableRowState();
}

class _AppTableRowState extends State<AppTableRow> {
  var _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: _tableRowContent(hover: _hover, columns: widget.columns),
    );
  }
}

Widget appTableRow({Key? key, required List<Widget> columns}) {
  return AppTableRow(key: key, columns: columns);
}

typedef AppTableRowBuilder = Widget Function(int index);

class AppTable extends StatefulWidget {
  final List<Widget> headers;
  final int itemCount;
  final AppTableRowBuilder rowBuilder;
  final int rowsPerPage;
  final bool expand;

  const AppTable({
    super.key,
    required this.headers,
    required this.itemCount,
    required this.rowBuilder,
    this.rowsPerPage = 30,
    this.expand = true,
  });

  @override
  State<AppTable> createState() => _AppTableState();
}

class _AppTableState extends State<AppTable> {
  final ValueNotifier<int> _currentPage = ValueNotifier(0);
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void didUpdateWidget(covariant AppTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    final totalPages = widget.itemCount == 0
        ? 1
        : (widget.itemCount / widget.rowsPerPage).ceil();
    if (_currentPage.value >= totalPages) {
      _currentPage.value = (totalPages - 1).clamp(0, totalPages);
    }
  }

  @override
  void dispose() {
    _currentPage.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _currentPage,
      builder: (context, currentPage, _) {
        final body = _tableBody(
          context: context,
          headers: widget.headers,
          itemCount: widget.itemCount,
          rowBuilder: widget.rowBuilder,
          rowsPerPage: widget.rowsPerPage,
          currentPage: currentPage,
          horizontalScrollController: _horizontalScrollController,
          onPageChanged: (page) => _currentPage.value = page,
        );

        // Expanded só pode ser filho direto de Flex. Quando a página já envolve
        // a tabela em Expanded (ex.: com ValueListenableBuilder no meio), use expand: false.
        if (widget.expand) return Expanded(child: body);
        return SizedBox.expand(child: body);
      },
    );
  }
}

Widget _tableRowContent({required bool hover, required List<Widget> columns}) {
  return Container(
    decoration: BoxDecoration(
      color: hover
          ? ConvertixColors.primaryLight.withValues(alpha: 0.45)
          : ConvertixColors.surface,
      border: Border(
        bottom: BorderSide(color: ConvertixColors.border, width: 1),
      ),
    ),
    child: Row(children: columns),
  );
}

Widget _tableBody({
  required BuildContext context,
  required List<Widget> headers,
  required int itemCount,
  required AppTableRowBuilder rowBuilder,
  required int rowsPerPage,
  required int currentPage,
  required ScrollController horizontalScrollController,
  required ValueChanged<int> onPageChanged,
}) {
  final startIndex = currentPage * rowsPerPage;
  final endIndex = (startIndex + rowsPerPage).clamp(0, itemCount);
  final visibleCount = (endIndex - startIndex).clamp(0, itemCount);

  if (visibleCount <= 0) {
    return Column(children: [Expanded(child: _tableEmptyState())]);
  }

  return appContainer(
    backgroundColor: ConvertixColors.surface,
    radius: BorderRadius.circular(AppTheme.radiusCard),
    border: Border.all(color: ConvertixColors.border),
    shadow: BoxShadow(
      color: ConvertixColors.textPrimary.withValues(alpha: AppTheme.shadowOpacity),
      blurRadius: AppTheme.shadowBlur,
      offset: const Offset(0, 4),
    ),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth = constraints.maxWidth;
        final screenWidth = MediaQuery.sizeOf(context).width;
        final isScrollable = screenWidth < tableScrollBreakpoint ||
            headers.length > tableScrollColumnThreshold;

        return TableBreakpointScope(
          tableWidth: tableWidth,
          isScrollable: isScrollable,
          child: isScrollable
              ? _tableScrollableBody(
                  constraints: constraints,
                  headers: headers,
                  itemCount: itemCount,
                  startIndex: startIndex,
                  visibleCount: visibleCount,
                  rowBuilder: rowBuilder,
                  rowsPerPage: rowsPerPage,
                  currentPage: currentPage,
                  horizontalScrollController: horizontalScrollController,
                  onPageChanged: onPageChanged,
                )
              : _tableFixedBody(
                  headers: headers,
                  itemCount: itemCount,
                  startIndex: startIndex,
                  visibleCount: visibleCount,
                  rowBuilder: rowBuilder,
                  rowsPerPage: rowsPerPage,
                  currentPage: currentPage,
                  onPageChanged: onPageChanged,
                ),
        );
      },
    ),
  );
}

Widget _tableFixedBody({
  required List<Widget> headers,
  required int itemCount,
  required int startIndex,
  required int visibleCount,
  required AppTableRowBuilder rowBuilder,
  required int rowsPerPage,
  required int currentPage,
  required ValueChanged<int> onPageChanged,
}) {
  return Column(
    children: [
      _tableHeader(headers: headers, isScrollable: false),
      Expanded(
        child: ListView.builder(
          itemCount: visibleCount,
          itemBuilder: (context, i) => rowBuilder(startIndex + i),
        ),
      ),
      _tablePaginationControls(
        totalRows: itemCount,
        rowsPerPage: rowsPerPage,
        currentPage: currentPage,
        onPageChanged: onPageChanged,
      ),
    ],
  );
}

Widget _tableScrollableBody({
  required BoxConstraints constraints,
  required List<Widget> headers,
  required int itemCount,
  required int startIndex,
  required int visibleCount,
  required AppTableRowBuilder rowBuilder,
  required int rowsPerPage,
  required int currentPage,
  required ScrollController horizontalScrollController,
  required ValueChanged<int> onPageChanged,
}) {
  final scrollWidth = headers.length * fixedCellWidth;
  final needsHorizontalScroll = scrollWidth > constraints.maxWidth;

  return Column(
    children: [
      Expanded(
        child: SingleChildScrollView(
          controller: horizontalScrollController,
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: scrollWidth,
            child: Column(
              children: [
                _tableHeader(headers: headers, isScrollable: true),
                Expanded(
                  child: ListView.builder(
                    itemCount: visibleCount,
                    itemBuilder: (context, i) => rowBuilder(startIndex + i),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      if (needsHorizontalScroll)
        _tableHorizontalScrollBar(controller: horizontalScrollController),
      _tablePaginationControls(
        totalRows: itemCount,
        rowsPerPage: rowsPerPage,
        currentPage: currentPage,
        onPageChanged: onPageChanged,
      ),
    ],
  );
}

Widget _tableHeader({required List<Widget> headers, required bool isScrollable}) {
  final headerRow = SizedBox(
    height: tableRowHeight,
    child: Row(
      mainAxisSize: isScrollable ? MainAxisSize.min : MainAxisSize.max,
      children: List.generate(headers.length, (index) {
        final header = headers[index];
        final data = tableHeaderDataFrom(header);
        if (data == null) return header;

        return _tableHeaderCell(
          data: data,
          isLast: index == headers.length - 1,
          fixed: isScrollable,
        );
      }),
    ),
  );

  return ClipRRect(
    borderRadius: const BorderRadius.vertical(
      top: Radius.circular(AppTheme.radiusCard),
    ),
    child: appContainer(
      backgroundColor: PanelHeaderStyle.background,
      height: tableRowHeight,
      border: Border(bottom: BorderSide(color: PanelHeaderStyle.borderColor)),
      child: headerRow,
    ),
  );
}

Widget _tableHeaderCell({
  required TableHeaderData data,
  required bool isLast,
  required bool fixed,
}) {
  final cell = Container(
    height: tableRowHeight,
    width: fixed ? fixedCellWidth : null,
    decoration: BoxDecoration(
      border: isLast
          ? null
          : Border(
              right: BorderSide(color: PanelHeaderStyle.dividerColor, width: 1),
            ),
    ),
    padding: const EdgeInsets.symmetric(horizontal: tableCellPadding),
    alignment: data.alignment,
    child: appText(
      data.title.toUpperCase(),
      color: PanelHeaderStyle.titleColor,
      letterSpacing: 0.8,
      fontSize: AppFontSizes.verySmall,
      bold: true,
      overflow: true,
    ),
  );

  if (fixed) return cell;
  return Expanded(flex: data.flex, child: cell);
}

Widget _tableEmptyState() {
  return appContainer(
    radius: BorderRadius.circular(AppTheme.radiusCard),
    width: double.infinity,
    backgroundColor: ConvertixColors.surface,
    border: Border.all(color: ConvertixColors.border),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: ConvertixColors.textMuted),
          appSizedBox(height: AppSpacing.normal),
          appText(
            'Nenhum item encontrado',
            fontSize: AppFontSizes.verySmall,
            bold: true,
            color: ConvertixColors.textPrimary,
          ),
          appSizedBox(height: AppSpacing.small),
          appText(
            'Verifique os filtros ou cadastre um novo item.',
            color: ConvertixColors.textSecondary,
          ),
        ],
      ),
    ),
  );
}

Widget _tableHorizontalScrollBar({required ScrollController controller}) {
  return Container(
    height: 18,
    width: double.infinity,
    decoration: BoxDecoration(
      color: ConvertixColors.background,
      border: Border(top: BorderSide(color: ConvertixColors.border)),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    child: LayoutBuilder(
      builder: (context, constraints) {
        return ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            if (!_tableScrollPositionReady(controller)) {
              return _tableScrollTrackBackground();
            }

            final position = controller.positions.first;
            final maxScroll = position.maxScrollExtent;
            if (maxScroll <= 0) return const SizedBox.shrink();

            final trackWidth = constraints.maxWidth;
            if (trackWidth <= 0) return _tableScrollTrackBackground();

            final viewport = position.viewportDimension;
            final contentWidth = viewport + maxScroll;
            final thumbWidth = (trackWidth * viewport / contentWidth).clamp(40.0, trackWidth);
            final scrollRange = trackWidth - thumbWidth;
            final thumbLeft = scrollRange <= 0
                ? 0.0
                : (position.pixels / maxScroll) * scrollRange;

            return _tableScrollThumb(
              controller: controller,
              maxScroll: maxScroll,
              scrollRange: scrollRange,
              thumbWidth: thumbWidth,
              thumbLeft: thumbLeft,
            );
          },
        );
      },
    ),
  );
}

Widget _tableScrollThumb({
  required ScrollController controller,
  required double maxScroll,
  required double scrollRange,
  required double thumbWidth,
  required double thumbLeft,
}) {
  void scrollByDelta(double delta) {
    if (!_tableScrollPositionReady(controller)) return;
    if (scrollRange <= 0) return;
    final scrollDelta = delta * maxScroll / scrollRange;
    controller.jumpTo((controller.offset + scrollDelta).clamp(0.0, maxScroll));
  }

  void jumpToPosition(double localDx) {
    if (!_tableScrollPositionReady(controller)) return;
    if (scrollRange <= 0) return;
    final ratio = ((localDx - thumbWidth / 2) / scrollRange).clamp(0.0, 1.0);
    controller.jumpTo(ratio * maxScroll);
  }

  return GestureDetector(
    behavior: HitTestBehavior.opaque,
    onHorizontalDragUpdate: (details) => scrollByDelta(details.delta.dx),
    onTapDown: (details) {
      final dx = details.localPosition.dx;
      if (dx < thumbLeft || dx > thumbLeft + thumbWidth) {
        jumpToPosition(dx);
      }
    },
    child: Stack(
      alignment: Alignment.centerLeft,
      children: [
        _tableScrollTrackBackground(),
        Positioned(
          left: thumbLeft,
          child: MouseRegion(
            cursor: SystemMouseCursors.grab,
            child: Container(
              width: thumbWidth,
              height: 8,
              decoration: BoxDecoration(
                color: ConvertixColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _tableScrollTrackBackground() {
  return Container(
    height: 8,
    decoration: BoxDecoration(
      color: ConvertixColors.border.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(4),
    ),
  );
}

bool _tableScrollPositionReady(ScrollController controller) {
  if (!controller.hasClients) return false;
  final position = controller.positions.first;
  return position.hasViewportDimension && position.hasContentDimensions;
}

Widget _tablePaginationControls({
  required int totalRows,
  required int rowsPerPage,
  required int currentPage,
  required ValueChanged<int> onPageChanged,
}) {
  final totalPages = (totalRows / rowsPerPage).ceil();

  return appContainer(
    backgroundColor: ConvertixColors.background,
    border: Border(top: BorderSide(color: ConvertixColors.border)),
    child: Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.normal,
        vertical: AppSpacing.small + 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _tableItemsBadge(totalRows),
          _tablePaginationButtons(
            currentPage: currentPage,
            totalPages: totalPages,
            onPageChanged: onPageChanged,
          ),
        ],
      ),
    ),
  );
}

Widget _tableItemsBadge(int totalRows) {
  return appContainer(
    height: 30,
    radius: BorderRadius.circular(AppTheme.radiusInput),
    gradient: ConvertixColors.primaryGradient,
    padding: EdgeInsets.symmetric(horizontal: AppSpacing.normal),
    child: Center(
      child: Row(
        children: [
          appText(totalRows.toString(), color: AppColors.white, bold: true),
          appSizedBox(width: AppSpacing.small),
          appText('ITENS', color: AppColors.white, bold: true),
        ],
      ),
    ),
  );
}

Widget _tablePaginationButtons({
  required int currentPage,
  required int totalPages,
  required ValueChanged<int> onPageChanged,
}) {
  return Row(
    children: [
      buttonAction(
        icon: Icons.chevron_left,
        width: 32,
        height: 32,
        iconSize: 20,
        tootip: 'Pagina anterior',
        onTap: () {
          if (currentPage > 0) onPageChanged(currentPage - 1);
        },
      ),
      appSizedBox(width: AppSpacing.normal),
      appText(
        '${currentPage + 1} de $totalPages',
        color: ConvertixColors.textSecondary,
      ),
      appSizedBox(width: AppSpacing.normal),
      buttonAction(
        icon: Icons.chevron_right,
        width: 32,
        height: 32,
        iconSize: 20,
        tootip: 'Proxima Pagina',
        onTap: () {
          if (currentPage < totalPages - 1) onPageChanged(currentPage + 1);
        },
      ),
    ],
  );
}
